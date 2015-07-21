Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754146AbbGUPvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jul 2015 11:51:45 -0400
Date: Tue, 21 Jul 2015 11:51:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Parallel file locking quite slow with vers=4.0 compared to vers=3
Message-ID: <20150721155144.GC11050@fieldses.org>
References: <55ACFF59.7040707@bio.ifi.lmu.de>
 <20150720212305.GB11050@fieldses.org>
 <55ADEA5C.8020607@bio.ifi.lmu.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55ADEA5C.8020607@bio.ifi.lmu.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 21, 2015 at 08:44:44AM +0200, Frank Steiner wrote:
> J. Bruce Fields wrote
> 
> > One way to confirm that might be to run client kernels modified to make
> > the polling behavior (controlled by
> > fs/nfs/nfs4proc.c:nfs4_set_lock_task_retry()) more aggressive, and see
> > if that removes the delays in your case.
> > 
> > If that works, then it might also be worth considering implementing
> > CB_NOTIFY_LOCK:
> > 
> > 	https://tools.ietf.org/html/rfc5661#page-593
> 
> I wouldn't mind to test any kind of patch if someone would find the time
> to provide some. Writing them myself is beyond my skills I'm afraid :-)

Well, I was just thinking of something like this.

(*Not* saying this is what we really want to do, but it might help
confirm where your delay is coming from.)

--b.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6f228b5..c119ba7 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5367,7 +5367,7 @@ int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4
 	return err;
 }
 
-#define NFS4_LOCK_MINTIMEOUT (1 * HZ)
+#define NFS4_LOCK_MINTIMEOUT (1 * HZ / 10)
 #define NFS4_LOCK_MAXTIMEOUT (30 * HZ)
 
 /* 
