From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: have string-based mount options default to
 "intr" mounts
Date: Wed, 25 Jul 2007 15:36:18 -0400
Message-ID: <46A7A632.2050900@oracle.com>
References: <20070725145614.e17ca721.jlayton@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020103080901070009010403"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDmf4-0005Fs-LS
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:36:42 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDmf7-0000Ew-93
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:36:46 -0700
In-Reply-To: <20070725145614.e17ca721.jlayton@redhat.com>
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

This is a multi-part message in MIME format.
--------------020103080901070009010403
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I thought "nointr" was the default because it is safest.

Jeff Layton wrote:
> The current string-based mount options default to "nointr" mounts. This
> is consistent with the current behavior of the struct-based mount
> options for NFSv2/3, but inconsistent with v4.
> 
> I've just sent a nfs-utils patch to make the default be "intr" for all
> NFS flavors. This patch makes the default the same when using
> string-based mount options.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b2a851c..55f9b8b 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1122,7 +1122,9 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
>  		char *c;
>  		int status;
>  		struct nfs_parsed_mount_data args = {
> -			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
> +			.flags		= (NFS_MOUNT_INTR |
> +					   NFS_MOUNT_VER3 |
> +					   NFS_MOUNT_TCP),
>  			.rsize		= NFS_MAX_FILE_IO_SIZE,
>  			.wsize		= NFS_MAX_FILE_IO_SIZE,
>  			.timeo		= 600,
> @@ -1608,6 +1610,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
>  	default: {
>  		unsigned int len;
>  		struct nfs_parsed_mount_data args = {
> +			.flags		= NFS4_MOUNT_INTR,
>  			.rsize		= NFS_MAX_FILE_IO_SIZE,
>  			.wsize		= NFS_MAX_FILE_IO_SIZE,
>  			.timeo		= 600,
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4

--------------020103080901070009010403
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------020103080901070009010403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020103080901070009010403
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020103080901070009010403--
