From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: ANNOUNCE: nfs-utils 1.0.4
Date: Thu, 31 Jul 2003 09:30:45 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16168.21797.220958.945676@gargle.gargle.HOWL>
References: <1030714170001.24267@cse.unsw.edu.au>
	<3F2681A6.7E33A7E6@moving-picture.com>
	<16167.18330.605320.168421@gargle.gargle.HOWL>
	<3F27F5C1.8C0C3E79@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19i0PG-0004QK-00
	for <nfs@lists.sourceforge.net>; Wed, 30 Jul 2003 16:30:54 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <james-p@moving-picture.com>) (for <nfs@lists.sourceforge.net>)
	By note With Smtp ; Thu, 31 Jul 2003 09:30:45 +1000
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: message from James Pearson on Wednesday July 30
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday July 30, james-p@moving-picture.com wrote:
> 
> What is the 'best' way to enable /proc/fs/nfs? i.e. if nfsd is a module,
> then you can't mount /proc/fs/nfs until the module is loaded, which
> normally doesn't happen until rpc.nfsd is started - which is after
> exportfs has been run in the startup script ...

Well, the theory was that mounting the 'nfsd' filesystem would cause
nfsd.ko to be auto-loaded.  Unfortunately I never tested this
theory...

It almost works.  The problem is that the /proc/fs/nfs directory is
created by the nfsd module so you cannot 
   mount -t nfsd nfsd /proc/fs/nfsd
to autoload nfsd, because mount will complain that /proc/fs/nfsd
doesn't exist.

   mkdir -p /mnt/nfsd
   mount -t nfsd nfsd /mnt/nfsd
   mount --move /mnt/nfsd /proc/fs/nfs

shows that autoloading works, but obviously isn't a real solution.
I will need to get /proc/fs/nfs created permanently.  I see about
creating a patch soon.

> 
> Should /proc/fs/nfs be unmounted when the /etc/init.d/nfs is
> stopped?

It doesn't really matter.  It needs to be unmounted before you can
unload the module, but it shouldn't hurt to just leave it there.

> 
> Could there be problems if nfsd uses /proc/fs/nfs, then nfsd is shutdown
> and restarted without /proc/fs/nfs being mounted?

Not really.  The 'nfsd' filesystem is just an interface into the
kernel.  It doesn't store any real data and unmounting it doesn't
affect anything.  It just removed the interface.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
