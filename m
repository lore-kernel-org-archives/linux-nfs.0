From: "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: Status of mount.nfs
Date: Sun, 15 Jul 2007 10:31:14 +0200
Message-ID: <20070715083114.GB4158@uio.no>
References: <20070708191640.GA13962@uio.no>
	<18065.43199.104020.412029@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9zVc-0008Hr-W1
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 01:31:17 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9zVf-0008HS-Ds
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 01:31:20 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtp (Exim 4.50) id 1I9zVb-0007LG-6C
	for nfs@lists.sourceforge.net; Sun, 15 Jul 2007 10:31:15 +0200
Received: from sesse by trofast.sesse.net with local (Exim 3.36 #1 (Debian))
	id 1I9zVa-00017L-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Jul 2007 10:31:14 +0200
In-Reply-To: <18065.43199.104020.412029@notabene.brown>
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

On Mon, Jul 09, 2007 at 01:17:19PM +1000, Neil Brown wrote:
> nfs-utils-1.1.0 builds and install mount.nfs by default, and should be
> used with the new util-linux.

Just a few experiences with this after a week or so with the new default in
Debian:

 - The new mount is really more picky in several aspects. Most notably, it
   refuses to mount anything unless rpc.statd is running, which broke our
   NFS mounting on boot. Also, it seems to be less forgiving about portmapper
   registration; cfs (an encrypted filesystem based off NFS, it seems) sets
   up a server on port 3049 and expects "-o port=3049,nfsvers=2" to work. The
   new mount.nfs searches for a portmapper unless the udp option is also
   correctly set. I'm slightly surprised at this increase in strictness,
   given that I thought it was essentially the same code.
 - If you forget to install it suid (we strip suid bits automatically) you
   will of course break user mounts. :-)
 - The umount exit status is broken, which will cause odd failures on umount
   from the GNOME drive manager (basically, an empty error dialog box). Apply
   the patch I posted here earlier.

I guess that's all the traps I've fell into for now; I hope they'll make it
easier to make the move for other distributions.
 
/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
