From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] NFS: Error when mounting the same
	filesystem	with different options
Date: Tue, 05 Jun 2007 19:49:33 -0400
Message-ID: <1181087373.6108.18.camel@heimdal.trondhjem.org>
References: <17994.32412.173039.15055@notabene.brown>
	<20070517021323.32447.13696.stgit@heimdal.trondhjem.org>
	<18011.37209.579643.844330@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net,
	Ian Kent <raven@themaw.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvimU-0001PJ-JK
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 16:49:42 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HvimX-0007lk-Kd
	for nfs@lists.sourceforge.net; Tue, 05 Jun 2007 16:49:45 -0700
In-Reply-To: <18011.37209.579643.844330@notabene.brown>
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

On Tue, 2007-05-29 at 12:35 +1000, Neil Brown wrote:
> On Wednesday May 16, Trond.Myklebust@netapp.com wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Unless the user sets the NFS_MOUNT_NOSHAREDCACHE mount flag, we should
> > return EBUSY if the filesystem is already mounted on a superblock that
> > has set conflicting mount options.
> 
> I'm not very comfortable with the EBUSY return.
> This is something that I would really like "mount.nfs" to be aware of
> and at least produce useful error messages about.
> So it would be very nice to have a unique error code.
> 
> But it is not at all obvious what error code could be used.
> EEXIST possibly comes closes to the write meaning.
> The man page for mount doesn't list EEXIST as an option, but says:
>    Each  filesystem type may have its own special errors and its
>    own special behavior.
> 
> so that might be OK.
> 
> Would you be agreeable to changing the error code to EEXIST??
> 
> Then mount.nfs could suggest using "-o nosharecache" when EEXIST is
> returned.

EBUSY is what the VFS currently returns when it sees an attempt to
remount a partition with incompatible options (for instance trying to
remount the filesystem read-only if it is already mounted for
read-write). Is there any reason why we need to distinguish the two
cases?

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
