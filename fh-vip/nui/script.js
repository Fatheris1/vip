let countdownInterval = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'toggle') {
        const app = document.getElementById('app');
        if (data.display) {
            app.style.display = 'block';
            if (data.days !== undefined) {
                document.getElementById('days-remaining').innerText = data.days;
            }
            
            if (data.locales) {
                if (data.name) {
                    const welcomeText = data.locales['welcome'].replace('%s', data.name);
                    document.getElementById('ui-welcome').innerText = welcomeText;
                }
                
                document.getElementById('ui-membership-status').innerText = data.locales['membership_status'];
                
                if (data.level) {
                    document.getElementById('vip-level-num').innerText = data.level;
                    document.getElementById('ui-level-label').innerText = data.locales['vip_level'];
                }

                document.getElementById('ui-remaining-time').innerText = data.locales['remaining_time'];
                document.getElementById('ui-days').innerText = data.locales['days'];
                document.getElementById('ui-claim-bonus').innerText = data.locales['claim_bonus'];
                document.getElementById('ui-footer').innerText = data.locales['footer_text'];

                handleBonusTimer(data.bonusRemaining, data.locales);
            }
        } else {
            app.style.display = 'none';
            if (countdownInterval) {
                clearInterval(countdownInterval);
                countdownInterval = null;
            }
        }
    }
});

function handleBonusTimer(seconds, locales) {
    const btn = document.getElementById('action-btn-1');
    const btnText = document.getElementById('ui-claim-bonus');
    
    if (countdownInterval) clearInterval(countdownInterval);

    if (seconds > 0) {
        btn.disabled = true;
        btn.classList.add('disabled');
        
        let remaining = seconds;
        
        const updateTimer = () => {
            if (remaining <= 0) {
                clearInterval(countdownInterval);
                btn.disabled = false;
                btn.classList.remove('disabled');
                btnText.innerText = locales['claim_bonus'];
                return;
            }
            
            const hours = Math.floor(remaining / 3600);
            const minutes = Math.floor((remaining % 3600) / 60);
            const secs = remaining % 60;
            
            btnText.innerText = `${hours}h ${minutes}m ${secs}s`;
            remaining--;
        };
        
        updateTimer();
        countdownInterval = setInterval(updateTimer, 1000);
    } else {
        btn.disabled = false;
        btn.classList.remove('disabled');
        btnText.innerText = locales['claim_bonus'];
    }
}

function post(url, data = {}) {
    fetch(`https://${GetParentResourceName()}/${url}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(data)
    });
}

document.getElementById('close-btn').addEventListener('click', function() {
    post('close');
});

document.getElementById('action-btn-1').addEventListener('click', function() {
    post('a_1');
    post('close');
});

document.onkeydown = function (data) {
    if (data.which == 27) { // ESC
        post('close');
    }
};
