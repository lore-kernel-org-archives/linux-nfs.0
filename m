From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: have string-based mount options default to
 "intr" mounts
Date: Wed, 25 Jul 2007 15:41:07 -0400
Message-ID: <20070725154107.063c3b9a.jlayton@redhat.com>
References: <20070725145614.e17ca721.jlayton@redhat.com>
	<46A7A632.2050900@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDmjO-0005nu-CP
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:41:10 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IDmjQ-0001nA-FS
	for nfs@lists.sourceforge.net; Wed, 25 Jul 2007 12:41:14 -0700
In-Reply-To: <46A7A632.2050900@oracle.com>
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

On Wed, 25 Jul 2007 15:36:18 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> I thought "nointr" was the default because it is safest.
> 

I could see maybe with soft mounts, but in conjunction with a hard
mount (which is the default) is there danger of corruption?


> Jeff Layton wrote:
> > The current string-based mount options default to "nointr" mounts. This
> > is consistent with the current behavior of the struct-based mount
> > options for NFSv2/3, but inconsistent with v4.
> > 
> > I've just sent a nfs-utils patch to make the default be "intr" for all
> > NFS flavors. This patch makes the default the same when using
> > string-based mount options.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index b2a851c..55f9b8b 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -1122,7 +1122,9 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
> >  		char *c;
> >  		int status;
> >  		struct nfs_parsed_mount_data args = {
> > -			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
> > +			.flags		= (NFS_MOUNT_INTR |
> > +					   NFS_MOUNT_VER3 |
> > +					   NFS_MOUNT_TCP),
> >  			.rsize		= NFS_MAX_FILE_IO_SIZE,
> >  			.wsize		= NFS_MAX_FILE_IO_SIZE,
> >  			.timeo		= 600,
> > @@ -1608,6 +1610,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
> >  	default: {
> >  		unsigned int len;
> >  		struct nfs_parsed_mount_data args = {
> > +			.flags		= NFS4_MOUNT_INTR,
> >  			.rsize		= NFS_MAX_FILE_IO_SIZE,
> >  			.wsize		= NFS_MAX_FILE_IO_SIZE,
> >  			.timeo		= 600,
> > _______________________________________________
> > NFSv4 mailing list
> > NFSv4@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
