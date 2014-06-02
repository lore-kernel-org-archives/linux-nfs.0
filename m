Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:60749 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752244AbaFBTJR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 15:09:17 -0400
Date: Mon, 2 Jun 2014 19:10:29 +0000 (UTC)
From: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
To: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Message-ID: <2116194027.57919.1401736229722.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <1863565244.57055.1401703005363.JavaMail.zimbra@opinsys.fi>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi> <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi> <20140520102117.2582abac@tlielax.poochiereds.net> <2137177707.38241.1400684149690.JavaMail.zimbra@opinsys.fi> <20140521165304.4331255d@tlielax.poochiereds.net> <1863565244.57055.1401703005363.JavaMail.zimbra@opinsys.fi>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- Original Message -----
> From: "Tuomas Räsänen" <tuomasjjrasanen@opinsys.fi>
> 
> ----- Original Message -----
> > From: "Jeff Layton" <jlayton@poochiereds.net>
> .
> > Ok, now that I look closer at your stack trace the problem appears to
> > be that the unlock code is waiting for the lock context's io_count to
> > drop to zero before allowing the unlock to proceed.
> > 
> > That likely means that there is some outstanding I/O that isn't
> > completing, but it's possible that the problem is the CB_RECALL is
> > being ignored. This will probably require some analysis of wire captures.
> > 
> > In your earlier mail, you mentioned that the client was responding to
> > the CB_RECALL with NFS4ERR_BADHANDLE. Determining why that's happening
> > may be the best place to focus your efforts.
> > 
> > Now that I look, nfs4_callback_recall does this:
> > 
> >         res = htonl(NFS4ERR_BADHANDLE);
> >         inode = nfs_delegation_find_inode(cps->clp, &args->fh);
> >         if (inode == NULL)
> >                 goto out;
> > 
> > So it looks like it's not finding the delegation for some reason.
> > You'll probably need to hunt down which open gave you the delegation in
> > the first place and then sanity check the CB_RECALL request to
> > determine whether it's the client or server that's insane here...
> > 
> 
> Speaking of insanity, I'll try to describe some of our findings in hope
> someone helps us to get a better grasp of the issue.
> 
> OPEN requests seem valid to me, there does not seem be any real difference
> between with OPENs granting RECALLable delegations and OPENs granting
> delegations which cause BADHANDLEs to be returned when RECALLed. I don't
> have any ideas what to look for.. probably been staring at capturelogs for
> too long...
> 
> BADHANDLE resposes to CB_RECALLs seem to be fairly common in our environment
> and there is not clear link between those and the softlockups described
> describer earlier by Veli-Matti. BADHANDLEs can happen multiple times before
> the first softlockup. After the first softlockup, the system keeps
> experiencing lockups (with various tracebacks) with an increasing speed, so
> I guess only the very first trace is meaningful. And the very first
> traceback seems to always be the traceback posted by Veli-Matti in his first
> email.
> 
> The BADHANDLE situation is also quite volatile: if
> nfs_delegation_find_inode() is called again, a bit later, before returning
> from nfs4_callback_recall(), it returns a valid inode instead of NULL. What
> does this indicate? Somehow related to the nature of RCU?

Adding to what Tuomas just wrote, there seem to be different sequences
that result in BADHANDLEs. Just by looking at the dumpcap dumps, it
looks like they all happen close to sillyrenames if I read them 
correctly.

Here's one where the delegation is returned before first CB_RECALL from
the server. Both CB_RECALLs result in NFS4ERR_BADHANDLE as the client
has already returned the delegation and if I understand correctly there 
seems to be no code in nfsd to check whether the recalled delegation is
still valid on the server when BADHANDLE is received. Because of this
nfsd4_cb_recall_done() retries the request once with 2sec delay and then
marks the callback channel to be down. When the client next time sends
RENEW, it results in NFS4ERR_CB_PATH_DOWN that triggers all the
delegations to be returned to the server.


static void nfsd4_cb_recall_done(struct rpc_task *task, void *calldata)
{
...
        if (dp->dl_retries--) {
                rpc_delay(task, 2*HZ);
                task->tk_status = 0;
                rpc_restart_call_prepare(task);
                return;
        }
        nfsd4_mark_cb_down(clp, task->tk_status);
        cb->cb_done = true;
}

15387748 12:01:08.759023   10.249.0.2 -> 10.249.15.254 NFS 254 V4 Call DELEGRETURN StateID:0xe21e
15387751 12:01:08.759077 10.249.15.254 -> 10.249.0.2   NFS 214 V4 Reply (Call In 15387748) DELEGRETURN
15387757 12:01:08.759158 10.249.15.254 -> 10.249.0.2   NFS 226 V1 CB_COMPOUND Call <EMPTY> CB_RECALL
15387770 12:01:08.759541   10.249.0.2 -> 10.249.15.254 NFS 114 V1 CB_COMPOUND Reply (Call In 15387757) <EMPTY> CB_RECALL
15467475 12:01:10.763189 10.249.15.254 -> 10.249.0.2   NFS 226 V1 CB_COMPOUND Call <EMPTY> CB_RECALL
15467510 12:01:10.764042   10.249.0.2 -> 10.249.15.254 NFS 114 V1 CB_COMPOUND Reply (Call In 15467475) <EMPTY> CB_RECALL
16412787 12:01:40.362237   10.249.0.2 -> 10.249.15.254 NFS 174 V4 Call RENEW CID: 0x7cff
16412788 12:01:40.362266 10.249.15.254 -> 10.249.0.2   NFS 114 V4 Reply (Call In 16412787) RENEW Status: NFS4ERR_CB_PATH_DOWN

And as Tuomas wrote, there is no clear link between these and the
softlockups, but recalling all delegations at once makes this a suspect
in my untrained eyes.


Happy hacking!

Veli-Matti
