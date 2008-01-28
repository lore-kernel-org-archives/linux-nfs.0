From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 003/100] Fix incorrect assignment
Date: Mon, 28 Jan 2008 15:07:47 -0500
Message-ID: <20080128200747.GF16785@fieldses.org>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <1201303040-7779-2-git-send-email-bfields@citi.umich.edu> <1201303040-7779-3-git-send-email-bfields@citi.umich.edu> <6BE49033-E0B1-48CF-866C-030F5E28B10D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Prasad P <pvp@us.ibm.com>,
	Steve French <smfltc@us.ibm.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbYA1UHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 15:07:49 -0500
In-Reply-To: <6BE49033-E0B1-48CF-866C-030F5E28B10D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 12:40:33PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>> From: Prasad P <pvp@us.ibm.com>
>>
>> Dereferenced pointer "dentry" without checking and assigned to inode
>> in the declaration.
>>
>> (We could just delete the NULL checks that follow instead, as we never
>> get to the encode function in this particular case.  But it takes a
>> little detective work to verify that fact, so it's probably safer to
>> leave the checks in place.)
>
> I think adding a comment to this effect before the "dentry == NULL"  
> check would be beneficial.

OK.  How about this?

--b.

commit edd084f0dc22316bff9f4a25fc1fd8cccfbe82bd
Author: Prasad P <pvp@us.ibm.com>
Date:   Wed Oct 24 15:14:32 2007 -0500

    nfsd: Fix inconsistent assignment
    
    Dereferenced pointer "dentry" without checking and assigned to inode
    in the declaration.
    
    (We could just delete the NULL checks that follow instead, as we never
    get to the encode function in this particular case.  But it takes a
    little detective work to verify that fact, so it's probably safer to
    leave the checks in place.)
    
    Cc: Steve French <smfltc@us.ibm.com>
    Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 0e5fa11..1c3b765 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -221,12 +221,17 @@ static int nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, __be32 *p,
 		struct nfsd3_getaclres *resp)
 {
 	struct dentry *dentry = resp->fh.fh_dentry;
-	struct inode *inode = dentry->d_inode;
+	struct inode *inode;
 	struct kvec *head = rqstp->rq_res.head;
 	unsigned int base;
 	int n;
 	int w;
 
+	/*
+	 * Since this is version 2, the check for nfserr in
+	 * nfsd_dispatch actually ensures the following cannot happen.
+	 * However, it seems fragile to depend on that.
+	 */
 	if (dentry == NULL || dentry->d_inode == NULL)
 		return 0;
 	inode = dentry->d_inode;
