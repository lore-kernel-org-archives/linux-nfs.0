From: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Subject: Re: fh_verify
Date: Tue, 3 Sep 2002 13:47:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <006a01c25371$ea977700$9300a8c0@gridlock>
References: <003901c252d9$d92bea70$9300a8c0@gridlock> <15732.7439.949607.498380@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.pennswoods.net ([205.247.236.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17mHxA-000397-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Sep 2002 10:59:04 -0700
To: "Neil Brown" <neilb@cse.unsw.edu.au>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I'm trying to track down all of the things that I think could be the
problem. For one, I know that things are not getting mounted right.

the init script passed to the kernel has the following lines of importance:

mount-t nfs -o nolock,ro,vers=2 $SERVER:/      /ro
mount-t nfs -o nolock,ro,vers=2 $SERVER:/home/guest/share      /ro2
mount-t nfs -o nolock,rw,vers=2 $SERVER:/home/guest/$ID      /rw

#then the /dev on the ramdisk is renamed out of the way and a server version
of dev is mounted EXCLUDED

exec /sbin/init '#'

this should allow me to write to my home dir but it says I have a read only
file system. Perhaps a remount option in my fstab to change.



----- Original Message -----
From: "Neil Brown" <neilb@cse.unsw.edu.au>
To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Cc: "nfs" <nfs@lists.sourceforge.net>
Sent: Monday, September 02, 2002 10:23 PM
Subject: Re: [NFS] fh_verify


> On Monday September 2, nlafferty@pennswoods.net wrote:
> > I have recently set up a lan with three New Internet Computers booting
off
> > the network as outlined in the article (
> > http://www.dnalounge.com/backstage/src/kiosk ) . After many atempts I
have
> > finally gotten ALMOST a booting client.
> > I have been alternating testing with SysVinit and Busybox's init. If I
use
> > the normal init I get errors on the NFS server about fh_verify:
/etc/shadow
> > permission failure. As soon as inittab is read. I get the same errors
when I
> > run sulogin. If I rename the inittab out of the way I can only boot in
> > single mode.
> >
> > If I use busybox it will boot. But I can not start X and I get the same
> > errors.
> >
> > Any clue? Any help would be great.
>
> Sounds like you need the
>    no_root_squash
> in you /etc/exports.  You definately need this for exporting a root
> filesystem.
>
> NeilBrown
>
>
> -------------------------------------------------------
> This sf.net email is sponsored by: OSDN - Tired of that same old
> cell phone?  Get a new here for FREE!
> https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
