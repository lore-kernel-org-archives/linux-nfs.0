From: trond.myklebust@fys.uio.no
Subject: RE: NFS suport block sharing
Date: Thu, 19 Feb 2004 05:39:06 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <36604.207.214.87.84.1077165546.squirrel@webmail.uio.no>
References: <482A3FA0050D21419C269D13989C611302B07B87@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net,"Olaf Kirch" <okir@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Atg3C-0001jm-2R
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 20:44:38 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtfqP-0007Dk-Pw
	for nfs@lists.sourceforge.net; Wed, 18 Feb 2004 20:31:26 -0800
To: "Charles Lever" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07B87@lavender-fe.eng.netapp.com>
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

På on , 18/02/2004 klokka 18:27, skreiv Lever, Charles:
> > Is there really any sane application that requires you to
> > have different
> > rsize/wsize for the same filesystem?
>
> an application suite may want to mount one file system with
> forcedirectio (if such an option might exist), and another
> normally.  with the shared super block scheme, this is no
> longer possible.

Sure it is. Just add the equivalent of Olaf's patch for the
forcedirectio flag into the external patch that adds forcedirectio
support. "forcedirectio" does indeed not care about inode aliasing, but it
is the *only* such case.

> another typical use for having two unshared cached copies of
> a file is to test NFS client caching (and yes, we do this
> all the time).

<Cough, splutter>...

That sort of testing can be done using 2 real clients, or with your own
patch. Why force insane semantics on everyone else just in order to allow
for some doubtful testing convenience on behalf of the NFS
developers?

> if nothing else, /proc/mounts and /etc/mtab should reflect
> the true mount options in effect, and there should be some
> explanation of this bizarre phenomenon in the man page.  the
> way it works now is totally confusing.

/proc/mounts will always reflect the true mount options. It should just
read that information directly from the superblock.

/etc/mtab is not under kernel control, and has always been broken w.r.t.
NFS options: try typing things like "mount -oremount,tcp /mnt" for
instance, or see the behaviour when you type insane values for
rsize/wsize.
Sure we can document this, but I don't see it as an argument for
breaking the kernel cache consistency by opening for inode aliasing.

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
