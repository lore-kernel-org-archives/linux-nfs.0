From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on error
Date: Fri, 12 Mar 2010 23:14:13 +0900
Message-ID: <201003122314.IAD17160.OtJLHVMFOOSFFQ@I-love.SAKURA.ne.jp>
References: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: ext-jani.1.nikula@nokia.com, Trond.Myklebust@netapp.com,
	bfields@fieldses.org, neilb@suse.de, davem@davemloft.net,
	batsakis@netapp.com, bhalevy@panasas.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jani Nikula wrote:
> Signed-off-by: Jani Nikula <ext-jani.1.nikula@nokia.com>
> 
> ---
> 
> NOTE: I'm afraid I'm unable to test this; please consider this more a
> bug report than a complete patch.
> ---
Indeed, it has to be "return ERR_PTR(-EINVAL);".
Otherwise, it will trigger NULL pointer dereference some lines later.

    bc_sock = container_of(args->bc_xprt, struct svc_sock, sk_xprt);
    bc_sock->sk_bc_xprt = xprt;

This bug was introduced by f300baba5a1536070d6d77bf0c8c4ca999bb4f0f
"nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel" and
exists in 2.6.32 and later.
