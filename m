Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33018 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933493Ab2DSVkt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Apr 2012 17:40:49 -0400
Date: Thu, 19 Apr 2012 17:40:43 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: skip dead but not buried clients on PipeFS
 events
Message-ID: <20120419214043.GA23309@fieldses.org>
References: <20120419105707.32131.79719.stgit@localhost6.localdomain6>
 <4F8FF8D9.5080503@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F8FF8D9.5080503@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 19, 2012 at 03:36:57PM +0400, Stanislav Kinsbursky wrote:
> Sorry, but ignore this patch too.
> It can't be that simple because of these cl_count tricks in rpc_release_client...

OK.  Very minor whine:

> 
> 19.04.2012 14:57, Stanislav Kinsbursky пишет:
> >These clients can't be safely dereferenced if their counter in 0.
> >
> >Signee-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
> >
> >Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>

I don't mind fixing up trivial slips every now and then, but that double
signed-off-by seems to happen on a lot of your posts; could you figure
out what's up with your scripts?

--b.

> >
> >---
> >  net/sunrpc/clnt.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> >
> >diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >index 6797246..591994d 100644
> >--- a/net/sunrpc/clnt.c
> >+++ b/net/sunrpc/clnt.c
> >@@ -218,7 +218,8 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
> >  		if (((event == RPC_PIPEFS_MOUNT)&&  clnt->cl_dentry) ||
> >  		    ((event == RPC_PIPEFS_UMOUNT)&&  !clnt->cl_dentry))
> >  			continue;
> >-		atomic_inc(&clnt->cl_count);
> >+		if (atomic_inc_return(&clnt->cl_count) == 1)
> >+			continue;
> >  		spin_unlock(&sn->rpc_client_lock);
> >  		return clnt;
> >  	}
> >
> 
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
