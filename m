From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RFC: mount.nfs
Date: Fri, 27 Aug 2004 14:13:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093630421.5758.42.camel@lade.trondhjem.org>
References: <20040827141529.GF23324@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0lET-0000BE-5N
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 11:13:49 -0700
Received: from dh138.citi.umich.edu
	([141.211.133.138] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C0lES-0002JX-ND
	for nfs@lists.sourceforge.net; Fri, 27 Aug 2004 11:13:49 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040827141529.GF23324@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 fr , 27/08/2004 klokka 10:15, skreiv Olaf Kirch:
> Please find attached the code for mount.nfs, a drop-in replacement for
> the nfsmount code in mount(8). If you're adventurous, simply compile,
> and install in /sbin as mount.nfs.
>=20
> Beware - this is alpha code I just wrote this morning; I'm running
> this past this list mostly in order to get feedback.
>=20
> I rewrote the code almost entirely from scratch, because I felt the
> old code had gotten a little convoluted. The new code should also
> be a lot smarter about which NFS and MOUNT versions to try, and which
> transport protocols. It currently prefers TCP over UDP, because that's
> what I like better, but if people disagree it's easy to turn this into
> a compile time option.

Yay! This sort of thing has been on my "TODO" list for some time.

Note though that pmap_getmaps() is not supported on legacy portmappers
(I think someone complained that their AIX system broke). This is why
the rewrite that is in Fedora Core 2 goes to such lengths to actually
"ping" the server.

Also note that ideally, we want to make stuff like this as part of a
backend library, then have 3 different programs:
  mount.nfs2
  mount.nfs3
  mount.nfs4
that can be called when the user does

    mount -t nfs -onfsvers=3D%d

The reason why I want to split out nfs2 from the nfs3 mount is that at
some point in the near future, I'd like to change the filesystem
registration to create 'struct file_system_type' entries for NFSv2 and
NFSv3. That will enable us to

   a) clean up the struct nfs_mount to get rid of all that "struct
socket", version 1 legacy crap
   b) be able to enumerate exactly which NFS versions the kernel has
been compiled to support by using 'cat /proc/filesystems'.

Cheers,
 Trond


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
