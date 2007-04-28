From: Neil Brown <neilb@suse.de>
Subject: Re: 2.6.21 strange optimization in svcauth_unix.c
Date: Sat, 28 Apr 2007 19:27:25 +1000
Message-ID: <17971.4989.320259.441338@notabene.brown>
References: <20070427171941.GA27920@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhjDU-00060z-Bz
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 02:27:44 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhjDW-0008Bt-IU
	for nfs@lists.sourceforge.net; Sat, 28 Apr 2007 02:27:47 -0700
In-Reply-To: message from Frank van Maarseveen on Friday April 27
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday April 27, frankvm@frankvm.com wrote:
> While reading the 2.6.21 version of net/sunrpc/svcauth_unix.c it looks
> to me that it tries to cache the AUTH_UNIX/AUTH_SYS group list on uid
> basis and thus deliberately ignore the group ids supplied by the NFS
> client.

It is configurable by a switch to mountd, and defaults to 'off'.

When a request arrives, the kernel tries to ask mountd to map the uid
to a list of gids.  If mountd says "no", the kernel uses whatever was
in the RPC request.  If mountd says "yes", the kernel uses the group
list that mountd provided.  mountd can provide a full list of gids,
not just the first 16.

So it is really an alternate to hacking the NFS client.  If you have a
new kernel and new nfs-utils and run mountd with "-g", you don't need
your changes to the NFS client.

I think that it is extremely uncommon to have a different group list
on the client than on the server, so doing the uid -> grouplist
mapping on the server shouldn't cause any surprises.
Note that this scheme leaves the primary groupid unchanged, so a
"newgrp" on the client will still work as expected.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
