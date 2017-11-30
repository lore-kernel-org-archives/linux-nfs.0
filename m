Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38390 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751943AbdK3Qd6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 11:33:58 -0500
Date: Thu, 30 Nov 2017 11:33:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: "Lu, Xinyu" <luxy.fnst@cn.fujitsu.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: pyNFS: testLongCompound
Message-ID: <20171130163357.GF11610@parsley.fieldses.org>
References: <0a272282-92cd-ce68-1892-591d952b1578@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0a272282-92cd-ce68-1892-591d952b1578@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 30, 2017 at 08:44:33AM +0000, Lu, Xinyu wrote:
> I'm puzzled about the result of nfs4.0/servertests/st_compound/testLongCompound in pyNFS.
> 
> The test increases the number of requests in the compound, and expects the server to return NFS 4 ERR RESOURCE when the number of requests reaches the upper limit on the server side.
> 
> In the RHEL 7.4GA source code, after NFS4ERR_BADXDR is returned after the number of requests reaches the server limit, RPC_GARBAGE_ARGS is returned in the dispatch function.
> 
> According to RFC 7530, when the server parses COMPOUND, it returns NFS 4 ERR RESOURCE if the resource is insufficient. If an error occurs when parsing XDR, NFS4ERR_BADXDR is returned.
> Requests in Compound are parsed in XDR. Therefore, I decide here that NFS4ERR_BADXDR should be returned. The testcase should be passed here. However,the result is failure.

I agree it's a bug, though not likely to cause problems for clients in
practice.

I wrote the following patch, but I think it's not quite correct--I need
to take another look.

(By the way this was written in response to another report from you, I
think--the name was the same but the email address was different.  Which
name and address would you like me to use to credit you?)

--b.

commit fd9a5e1c4952
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Nov 15 12:30:27 2017 -0500

    nfsd: return RESOURCE not GARBAGE_ARGS on too many ops
    
    A client that sends more than a hundred ops in a single compound
    currently gets an rpc-level GARBAGE_ARGS error.
    
    It would be more helpful to return NFS4ERR_RESOURCE, since that gives
    the client a better idea how to recover (for example by splitting up the
    compound into smaller compounds).
    
    This is all a bit academic since we've never actually seen a reason for
    clients to send such long compounds, but we may as well fix it.
    
    While we're there, just use NFSD4_MAX_OPS_PER_COMPOUND == 16, the
    constant we already use in the 4.1 case, instead of hard-coding 100.
    Chances anyone actually uses even 16 ops per compound are small enough
    that I think there's a neglible risk or any regression.
    
    This fixes pynfs test COMP6.
    
    Reported-by: sunlianwen <sunlw.fnst@cn.fujitsu.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 008ea0b627d0..c9669d75c157 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1703,6 +1703,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 	status = nfserr_minor_vers_mismatch;
 	if (nfsd_minorversion(args->minorversion, NFSD_TEST) <= 0)
 		goto out;
+	status = nfserr_resource;
+	if (resp->opcnt > NFSD_MAX_OPS_PER_COMPOUND)
+		goto out;
 
 	status = nfs41_check_op_ordering(args);
 	if (status) {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2c61c6b8ae09..5dcd7cb45b2d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1918,8 +1918,13 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 
 	if (argp->taglen > NFSD4_MAX_TAGLEN)
 		goto xdr_error;
-	if (argp->opcnt > 100)
-		goto xdr_error;
+	/*
+	 * NFS4ERR_RESOURCE is a more helpful error than GARBAGE_ARGS
+	 * here, so we return success at the xdr level so that
+	 * nfsd4_proc can handle this is an NFS-level error.
+	 */
+	if (argp->opcnt > NFSD_MAX_OPS_PER_COMPOUND)
+		return 0;
 
 	if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
 		argp->ops = kzalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
