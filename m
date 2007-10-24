From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Fix incorrect assignment
Date: Wed, 24 Oct 2007 16:57:36 -0400
Message-ID: <20071024205736.GL29830@fieldses.org>
References: <OFE5621A0A.80A31B03-ON8725737E.006E4E77-8625737E.006F322A@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Prasad P <pvp@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IknIF-0001zu-BH
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 13:57:35 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IknIK-0008G4-L4
	for nfs@lists.sourceforge.net; Wed, 24 Oct 2007 13:57:41 -0700
In-Reply-To: <OFE5621A0A.80A31B03-ON8725737E.006E4E77-8625737E.006F322A@us.ibm.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, Oct 24, 2007 at 03:14:32PM -0500, Prasad P wrote:
> 
> 
> Dereferenced pointer "dentry" without checking and assigned to inode
> in the declaration.

Seems reasonable, but: looking at nfsd_dispatch(), it appears that the
encode function is never called in this case (since rq_vers == 2 and
nfsacld_proc_getacl() would have returned an error if it couldn't find a
dentry).  Am I missing something?  Do you have a test case?

--b.


> 
> Cc: Steve French <smfltc@us.ibm.com>
> Signed-off-by: Prasad V Potluri <pvp@us.ibm.com>
> ---
> 
> diff -uprN a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
> --- a/fs/nfsd/nfs2acl.c 2007-10-09 15:31:38.000000000 -0500
> +++ b/fs/nfsd/nfs2acl.c 2007-10-24 14:03:13.000000000 -0500
> @@ -221,7 +221,7 @@ static int nfsaclsvc_encode_getaclres(st
>             struct nfsd3_getaclres *resp)
>  {
>       struct dentry *dentry = resp->fh.fh_dentry;
> -     struct inode *inode = dentry->d_inode;
> +     struct inode *inode;
>       struct kvec *head = rqstp->rq_res.head;
>       unsigned int base;
>       int n;
> --
> Thanks.
> 
> Regards,
> Prasad Potluri
> email: pvp at-sign us dot ibm dot com
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >> http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
