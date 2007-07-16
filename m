From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 00/17] RFC: proposed changes to the NFS mount
	command
Date: Mon, 16 Jul 2007 14:05:34 +1000
Message-ID: <18074.61070.150991.554588@notabene.brown>
References: <20070716030150.11209.85724.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IAHpy-0006sz-Mw
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:05:30 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IAHq1-0005cP-TK
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 21:05:34 -0700
In-Reply-To: message from Chuck Lever on Sunday July 15
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

On Sunday July 15, chuck.lever@oracle.com wrote:
> Hi Neil-
> 
> I've got a series of patches to the NFS mount command that prepare it
> for using a C string to pass mount options to the kernel, rather than
> a binary nfs_mount_data structure.

I've wondered why that was happening... Can't we just make a version
x+1 with a big string buffer so new options get put there is regular
string format and old options stay the way they are?

But I guess that - long term - it is better to be just like other
filesystems.


> 
> The goal of these clean-ups is to allow the creation of a ./configure
> option that will disable building nfsmount.c and nfs4mount.c, and
> enable building a version of these files that will introduce support
> for passing mount options as a string (that work is yet to be done).

Does this mean that you cannot compile nfs-utils to support both old
and new kernels?  Is that really a good plan?
What is the over-all migration strategy?


> 
> They certainly need some testing yet, but can you take a look at these
> and tell me if they are generally acceptable or if I need to take a
> different direction?  Hopefully they are straightforward and won't take
> much of your time.

Some of these are obviously good cleanups.  Would it inconvenience you
if I just picked off the ones I like for now and leave you to rebase?

I've replied to the ones I had specific concerns about.  Others are OK
providing it really does make sense to have an either-or
configuration.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
