From: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Subject: Re: Can't mount nfs rw
Date: Thu, 5 Sep 2002 10:46:48 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002d01c254eb$115472b0$9300a8c0@gridlock>
References: <003e01c2543a$0cb85ac0$9300a8c0@gridlock> <15734.49824.606700.166745@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.pennswoods.net ([205.247.236.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17my64-0001NF-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Sep 2002 07:59:04 -0700
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

I'm not quite sure I know your perlf00. What does :   perl -i -p -e
's,192.168.0.0\(,192.168.0.0/255.255.255.0\(,' /etc/exports  actually do? I
issue the command and it just hangs. Does it change my exports file in some
way?

Thanks,

Nick

----- Original Message -----
From: "Neil Brown" <neilb@cse.unsw.edu.au>
To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
Cc: "nfs" <nfs@lists.sourceforge.net>
Sent: Wednesday, September 04, 2002 10:34 PM
Subject: Re: [NFS] Can't mount nfs rw


> On Wednesday September 4, nlafferty@pennswoods.net wrote:
> > I'm having problems getting my diskless clients to mount NFS directories
in
> > Read-Write mode. I'm using bpbatch and tftp to transfer the kernel and a
> > ramdisk for the root file system. I pass an initscript to the kernel
that
> > mounts the root file system of the server as read-only (mounts on /ro),
> > /home/guest/share mounts as ro2 (read-only), and /home/guest/01 mounts
as
> > /rw (read-write). Then init is invoked. The problem is that all of the
> > mounts are read-only.
> >
> > #Here is what my initscript does for the mounts.
> > mount-t nfs -o nolock,ro,vers=2 $SERVER:/      /ro
> > mount-t nfs -o nolock,ro,vers=2 $SERVER:/home/guest/share      /ro2
> > mount-t nfs -o nolock,rw,vers=2 $SERVER:/home/guest/$ID      /rw
> >
> > /sbin/init '#'
> >
> > # Here is my /etc/exports
> > /
> > 192.168.0.0/255.255.255.0(ro,no_root_squash)
> > /home/guest/share       192.168.0.0(ro,no_root,squash)
> > /home/guest/01            192.168.0.0(rw,no_root_squash)
> > /home/guest/02            192.168.0.0(rw,no_root_squash)
> > /home/guest/03            192.168.0.0(rw,no_root_squash)
> >
> > Any suggestions on some other things to try?
> >
>
>
> perl -i -p -e 's,192.168.0.0\(,192.168.0.0/255.255.255.0\(,' /etc/exports
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
