From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] NFS: Error when mounting the same filesystem
	with different options
Date: Tue, 29 May 2007 12:35:05 +1000
Message-ID: <18011.37209.579643.844330@notabene.brown>
References: <17994.32412.173039.15055@notabene.brown>
	<20070517021323.32447.13696.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net,
	Ian Kent <raven@themaw.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HsrYX-00036H-5z
	for nfs@lists.sourceforge.net; Mon, 28 May 2007 19:35:29 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HsrYY-0004mG-TA
	for nfs@lists.sourceforge.net; Mon, 28 May 2007 19:35:32 -0700
In-Reply-To: message from Trond Myklebust on Wednesday May 16
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

On Wednesday May 16, Trond.Myklebust@netapp.com wrote:
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Unless the user sets the NFS_MOUNT_NOSHAREDCACHE mount flag, we should
> return EBUSY if the filesystem is already mounted on a superblock that
> has set conflicting mount options.

I'm not very comfortable with the EBUSY return.
This is something that I would really like "mount.nfs" to be aware of
and at least produce useful error messages about.
So it would be very nice to have a unique error code.

But it is not at all obvious what error code could be used.
EEXIST possibly comes closes to the write meaning.
The man page for mount doesn't list EEXIST as an option, but says:
   Each  filesystem type may have its own special errors and its
   own special behavior.

so that might be OK.

Would you be agreeable to changing the error code to EEXIST??

Then mount.nfs could suggest using "-o nosharecache" when EEXIST is
returned.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
