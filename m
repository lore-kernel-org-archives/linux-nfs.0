Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:64972 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752071AbbG2PR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2015 11:17:58 -0400
From: Andrew W Elble <aweits@rit.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, <linux-nfs@vger.kernel.org>,
        "Anna Schumaker" <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
References: <m23809zl8z.fsf@discipline.rit.edu>
	<m2zj2hwk4e.fsf@discipline.rit.edu>
	<20150728090206.1331e476@tlielax.poochiereds.net>
	<m2wpxktjfc.fsf@discipline.rit.edu>
	<20150728114933.6f917374@tlielax.poochiereds.net>
	<20150728210434.GC9349@fieldses.org>
Date: Wed, 29 Jul 2015 11:17:57 -0400
In-Reply-To: <20150728210434.GC9349@fieldses.org> (J. Bruce Fields's message
	of "Tue, 28 Jul 2015 17:04:34 -0400")
Message-ID: <m24mknq9ga.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Updates: slub_debug seems to interfere with this manifesting.

> so might be worth adding a WARN_ON_ONCE() or two here in
> nfsd4_process_open2 to confirm whether either the upgrade or
> release_open_stateid cases are dealing with a partially setup stateid.

I started with this - not completely sure this covers all the cases
we're interested in.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 039f9c8a95e8..bb54c7d7b787 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3866,6 +3866,8 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	if (!test_access(open->op_share_access, stp))
 		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
 
+	WARN_ON_ONCE(!find_readable_file(fp));
+
 	/* test and set deny mode */
 	spin_lock(&fp->fi_lock);
 	status = nfs4_file_check_deny(fp, open->op_share_deny);
@@ -4171,6 +4173,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		init_open_stateid(stp, fp, open);
 		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
 		if (status) {
+		        WARN_ON_ONCE(!find_readable_file(fp));
 			release_open_stateid(stp);
 			goto out;
 		}


...and quickly got the warning at the usual place, and inside of nfs4_upgrade_open()

[  836.784251] WARNING: CPU: 0 PID: 12114 at fs/nfsd/nfs4state.c:3869 nfsd4_process_open2+0xffd/0x1200 [nfsd]()
[  930.708782] WARNING: CPU: 2 PID: 12114 at fs/nfsd/nfs4state.c:3939 nfsd4_process_open2+0xe5a/0x1200 [nfsd]()
[ 1331.966806] WARNING: CPU: 2 PID: 12108 at lib/list_debug.c:53 __list_del_entry+0x63/0xd0()
[ 1332.294149] WARNING: CPU: 2 PID: 12108 at lib/list_debug.c:53 __list_del_entry+0x63/0xd0()

-- 
Andrew W. Elble
aweits@discipline.rit.edu
Infrastructure Engineer, Communications Technical Lead
Rochester Institute of Technology
PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
