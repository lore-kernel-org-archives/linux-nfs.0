From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Tue, 9 Oct 2007 11:37:15 +1000
Message-ID: <18186.56139.301135.961540@notabene.brown>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1If42D-0006wS-B9
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 18:37:29 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1If42I-0004qr-3u
	for nfs@lists.sourceforge.net; Mon, 08 Oct 2007 18:37:26 -0700
In-Reply-To: message from Chuck Lever on Monday October 8
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


First 5 OK and applied.  But I'm a bit uncertain about this one.
I think the rest are OK as well, so once we've sorted this one, the
rest can be applied.

Apart from the empty subject line :-), it doesn't look right.
In particular....

On Monday October 8, chuck.lever@oracle.com wrote:
> Introduce a function for probing the server for what it supports, and then
> rewriting the mount options using the probe results.

>  /*
> + * Reconstruct the mount option string based on a portmapper probe
> + * of the server.  Returns one if the server's portmapper returned
> + * something we can use, otherwise zero.
> + *
> + * Unfortunately, for fallback, we need to parse out the mount options
> + * in user space.  Unrecognized options are ignored here.

(I that paragraph of the comment still relevant?)

> + *
> + * Order of processing:
> + * 1.  fill in mnt_server and nfs_server, based on existing options

This statement doesn't seem to be true.
In particular, the 'version number' and 'proto' in the existing
options are *not* (that I can see) filled in for nfs_server.

So it would seem that
	mount -o vers=3  server:/path /dir

would fall back to v2 if 'server' didn't support v3.  I don't think
that is right (current mount.nfs doesn't do that).

Did I misunderstand the code?


By the by, when testing what the current code does, I discovered that
if

      mount server:/path /dir

falls back to v2 because the default (v3) doesn't work, then
     umount /dir

fails with

     umount.nfs: Server failed to unmount 'server:/path'

which is a worry.
I think there are two problem here:
  1/ we should fall back to v2 umount if v3 fails (well, the MOUNT
     versions  are different, but you know what I mean).
  2/ If the call to the server fails, we should still unmount the
     filesystem (call del_mtab .... not a good choice for the name
     of the function that does the actual unmount...)
Thoughts?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
