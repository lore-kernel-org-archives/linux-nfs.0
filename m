From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [PATCH] NFSD: do not return nfserr_symlink for the LINK	operation
Date: Fri, 20 Mar 2009 15:05:42 +0800
Message-ID: <49C34046.4060306@cn.fujitsu.com>
References: <49B2C404.3060907@panasas.com> <20090309180643.GB9408@fieldses.org> <49BA15B3.2040904@cn.fujitsu.com> <20090318230621.GK18894@fieldses.org> <49C1EB55.8060700@panasas.com> <49C1ED5B.6040000@cn.fujitsu.com> <49C1EE65.7010008@panasas.com> <49C1FFC7.6070709@cn.fujitsu.com> <49C20F6F.2040704@panasas.com> <49C21485.5070306@cn.fujitsu.com> <20090319200035.GC5499@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:64671 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752242AbZCTHGh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 03:06:37 -0400
In-Reply-To: <20090319200035.GC5499@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Mar 19, 2009 at 05:46:45PM +0800, Yang Hongyang wrote:
>> v1->v2:update some code style problem
>> -------------------------
>>
>> There are four placees that returned inappropriate err nfserr_symlink accroding to 
>> newpynfs test #LINK4a#LOOKP2a#OPCF3a#SATT12a.nfserr_symlink do not listed
>> in these operations's err list in the spec.
>> For LINK and LOOKUPP operation,nfserr_notdir should be returned.
>> For OPEN_CONFIRM and SETATTR operation,nfserr_inval should be returned.
> 
> I thought Benny found that this also caused the linux client to return a
> better error in one of these cases--could you confirm that and add a
> mention of it in the commit message?
> 
> (I'm reluctant to take patches like this based *only* on the spec
> language, partly because rfc 3530 is known to have a few oversights in
> the error listings.)
> 
> I definitely appreciate people going through the pynfs tests and
> investigating the results, but I don't want patch whose only
> justification is that they quiet pynfs--we need to think about the
> likely effect on real clients too.
> 
> --b.
> 

Just as Bruce said:
open_confirm is done with the same filehandle that was returned from a
previous OPEN.  But an OPEN should never return the filehandle for a
symlink.  That means for us to reach this case, either the client or our
filesystem has a very serious bug.  Therefore, I'm not convinced that
getting the error return correct in this case is worth the trouble.

OPEN_CONFIRM may never hit the error return.

And i did a test through following commands on a nfs4 fs:
#touch test
#ln -s test 1
#ln 1 2

It just creat a symlink 2 to test as on the local fs.Accroding to
this,I think link op will never hit the nfserr_symlink err return
either.

For the reasons above,There seems to be only one op *LOOKUPP* that
needs to be fixed.But still,I consider we should fix it all even the error
return won't be triggered through real client use cauz there can be
chances that a specially designed programme can triggered the bug.
If the bug is not the return value issue but a memory overflow or some
other strictness,the server may down by such attack.

-------------------------------------------------------------------------------------------
There are four placees that returned inappropriate err nfserr_symlink accroding to 
newpynfs test #LINK4a#LOOKP2a#OPCF3a#SATT12a.nfserr_symlink do not listed
in these operations's err list in the spec.
Benny Halevy pointed out  that the linux nfs client translates NFS4ERR_SYMLINK 
to -ELOOP which is awkward and less descriptive to the app/user than
-ENOTDIR. So a careful client implementation should never get NFS4ERR_SYMLINK
if it stats the directory it operates on before sending the link op (or lookup, create,
 rename, etc.) to make sure it is indeed a directory.
[Sigh, looking at the code - it looks like we'll return NFS4ERR_ISDIR for a 
length-changing SETATTR operating on a directory.  This is fine in NFSv4.0 
but this error was removed for SETATTR in nfs4.1.  Note to self: revise
this in the nfs41 tree]

Signed-off-by: Yang Hongyang <yanghy@cn.fujitsu.com>
Reviewed-by: Benny Halevy <bhalevy@panasas.com>

---
 fs/nfsd/nfs4proc.c  |    6 +++++-
 fs/nfsd/nfs4state.c |    6 +++++-
 fs/nfsd/vfs.c       |    6 ++++++
 3 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 9fa60a3..9aaecaa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -493,8 +493,12 @@ nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
-	return nfsd_lookup(rqstp, &cstate->current_fh,
+	ret = nfsd_lookup(rqstp, &cstate->current_fh,
 			   "..", 2, &cstate->current_fh);
+	/* nfserr_symlink returned is inappropriate for LOOKUPP */
+	if (ret == nfserr_symlink)
+		ret = nfserr_notdir;
+	return ret;
 }
 
 static __be32
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b6f60f4..28e4688 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2234,8 +2234,12 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			cstate->current_fh.fh_dentry->d_name.name);
 
 	status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0);
-	if (status)
+	if (status) {
+		/* nfserr_symlink returned is inappropriate for OPEN_CONFIRM */
+		if (status == nfserr_symlink)
+			status = nfserr_inval;
 		return status;
+	}
 
 	nfs4_lock_state();
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6e50aaa..015a655 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -397,6 +397,9 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
 		if (EX_ISSYNC(fhp->fh_export))
 			write_inode_now(inode, 1);
 out:
+	/* nfserr_symlink returned is inappropriate for SETATTR */
+	if (err == nfserr_symlink)
+		err = nfserr_inval;
 	return err;
 
 out_nfserr:
@@ -1637,6 +1640,9 @@ out_dput:
 out_unlock:
 	fh_unlock(ffhp);
 out:
+	/* nfserr_symlink returned is inappropriate for LINK */
+	if (err == nfserr_symlink)
+		err = nfserr_notdir;
 	return err;
 
 out_nfserr:
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
