From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 13330] New: nfs4 NULL pointer dereference in
 _nfs4_do_setlk
Date: Thu, 21 May 2009 17:27:49 -0400
Message-ID: <1242941269.22947.20.camel@heimdal.trondhjem.org>
References: <bug-13330-104@http.bugzilla.kernel.org/>
	 <1242939802.22947.17.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LEZI8/nWzYKPNezwvLfU"
Cc: Rich Ercolani <rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org>, Rince <rincebrain@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-nfs@vger.kernel.org
To: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37543 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753315AbZEUV1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 17:27:55 -0400
In-Reply-To: <1242939802.22947.17.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-LEZI8/nWzYKPNezwvLfU
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2009-05-21 at 17:03 -0400, Trond Myklebust wrote:
> On Sun, 2009-05-17 at 04:44 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
> wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=13330
> > 
> >            Summary: nfs4 NULL pointer dereference in _nfs4_do_setlk
> >            Product: File System
> >            Version: 2.5
> >     Kernel Version: 2.6.30-rc4
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: NFS
> >         AssignedTo: trond.myklebust@fys.uio.no
> >         ReportedBy: rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org
> >         Regression: No
> > 
> > 
> > Created an attachment (id=21380)
> >  --> (http://bugzilla.kernel.org/attachment.cgi?id=21380)
> > NFSv4 BUG ON log
> > 
> > My NFS server rebooted.
> > 
> > The machine with the kernel in question, one of many clients, spit out the
> > attached error in dmesg, and all NFS activity on the machine blocked forever,
> > necessitating a reboot.
> > 
> > This is not true on any of the other NFS clients on the network, which vary
> > between 2.6.18 and 2.6.27, so it may be A) 64-bit specific somehow (the rest
> > are 32-bit), B) recently introduced, or C) recently exposed by some existing
> > bad behavior in NFS recovery being removed.
> > 
> > Machine was "vanilla" 2.6.30-rc4 (with commits
> > b827e496c893de0c0f142abfaeb8730a2fd6b37f and
> > 7fdf523067666b0eaff330f362401ee50ce187c4 added), 64-bit. NFSv4 mounted with
> > rw,nosuid,nodev,noatime,hard,intr,nolock,sloppy,rsize=8192,wsize=8192,tcp,timeo=600.
> > 
> > I'll try reproducing this on latest GIT shortly, but it's hard to reproduce
> > (since it only occurs after the NFS server reboots, and not even consistently
> > then), so I don't know when I'll be able to report back that it occurs or not.
> 
> Switching to email...
> 
> I'm having trouble reproducing this, and staring at the code itself
> isn't helping (as far as I can see, the locking using nfsi->rwsem should
> work).
> 
> Could you therefore please try the attached patch?

You might also want to apply the attached fix to the RENEW function. It
corrects a bug that can cause NFSv4 clients to fail to recover state
during the grace period...

Cheers
  Trond

--=-LEZI8/nWzYKPNezwvLfU
Content-Description: NFSv4: Fix NFSv4 async renewal
Content-Type: application/mbox
Content-Disposition: inline; filename="linux-2.6.30-008-fix_async_renewal.dif"
Content-Transfer-Encoding: 7bit

>From 221aabd45da0c88b0aed6acfd1222fd50c1bbf04 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 21 May 2009 16:29:37 -0400
Subject: [PATCH] NFSv4: Fix NFSv4 async renewal

If the lease renewal fails due to a soft timeout, then we _must_ schedule a
new one...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c376d70..476d59e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2594,12 +2594,9 @@ static void nfs4_renew_done(struct rpc_task *task, void *data)
 	unsigned long timestamp = (unsigned long)data;
 
 	if (task->tk_status < 0) {
-		switch (task->tk_status) {
-			case -NFS4ERR_STALE_CLIENTID:
-			case -NFS4ERR_EXPIRED:
-			case -NFS4ERR_CB_PATH_DOWN:
-				nfs4_schedule_state_recovery(clp);
-		}
+		/* Unless we're shutting down, schedule state recovery! */
+		if (test_bit(NFS_CS_RENEWD, &clp->cl_res_state) != 0)
+			nfs4_schedule_state_recovery(clp);
 		return;
 	}
 	spin_lock(&clp->cl_lock);
-- 
1.6.0.4


--=-LEZI8/nWzYKPNezwvLfU--

