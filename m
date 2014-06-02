Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:58683 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752990AbaFBKBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 06:01:13 -0400
Date: Mon, 2 Jun 2014 09:56:45 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-ID: <1863565244.57055.1401703005363.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <20140521165304.4331255d@tlielax.poochiereds.net>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi> <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi> <20140520102117.2582abac@tlielax.poochiereds.net> <2137177707.38241.1400684149690.JavaMail.zimbra@opinsys.fi> <20140521165304.4331255d@tlielax.poochiereds.net>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Jeff Layton" <jlayton@poochiereds.net>
> 
.
.
.
> Ok, now that I look closer at your stack trace the problem appears to
> be that the unlock code is waiting for the lock context's io_count to
> drop to zero before allowing the unlock to proceed.
> 
> That likely means that there is some outstanding I/O that isn't
> completing, but it's possible that the problem is the CB_RECALL is
> being ignored. This will probably require some analysis of wire captures.
> 
> In your earlier mail, you mentioned that the client was responding to
> the CB_RECALL with NFS4ERR_BADHANDLE. Determining why that's happening
> may be the best place to focus your efforts.
> 
> Now that I look, nfs4_callback_recall does this:
> 
>         res = htonl(NFS4ERR_BADHANDLE);
>         inode = nfs_delegation_find_inode(cps->clp, &args->fh);
>         if (inode == NULL)
>                 goto out;
> 
> So it looks like it's not finding the delegation for some reason.
> You'll probably need to hunt down which open gave you the delegation in
> the first place and then sanity check the CB_RECALL request to
> determine whether it's the client or server that's insane here...
> 

Speaking of insanity, I'll try to describe some of our findings in hope someone helps us to get a better grasp of the issue.

OPEN requests seem valid to me, there does not seem be any real difference between with OPENs granting RECALLable delegations and OPENs granting delegations which cause BADHANDLEs to be returned when RECALLed. I don't have any ideas what to look for.. probably been staring at capturelogs for too long...

BADHANDLE resposes to CB_RECALLs seem to be fairly common in our environment and there is not clear link between those and the softlockups described describer earlier by Veli-Matti. BADHANDLEs can happen multiple times before the first softlockup. After the first softlockup, the system keeps experiencing lockups (with various tracebacks) with an increasing speed, so I guess only the very first trace is meaningful. And the very first traceback seems to always be the traceback posted by Veli-Matti in his first email.

The BADHANDLE situation is also quite volatile: if nfs_delegation_find_inode() is called again, a bit later, before returning from nfs4_callback_recall(), it returns a valid inode instead of NULL. What does this indicate? Somehow related to the nature of RCU? 

-- 
Tuomas
