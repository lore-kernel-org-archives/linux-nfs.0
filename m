From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Can't mount nfs rw
Date: Fri, 6 Sep 2002 10:24:12 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15735.62892.38035.663384@notabene.cse.unsw.edu.au>
References: <003e01c2543a$0cb85ac0$9300a8c0@gridlock>
	<15734.49824.606700.166745@notabene.cse.unsw.edu.au>
	<002d01c254eb$115472b0$9300a8c0@gridlock>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "nfs" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17n6vK-00035K-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Sep 2002 17:24:35 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <nlafferty@pennswoods.net>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 6 Sep 2002 10:24:20 +1000
To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
In-Reply-To: message from Nicholas Lafferty on Thursday September 5
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

On Thursday September 5, nlafferty@pennswoods.net wrote:
> I'm not quite sure I know your perlf00. What does :   perl -i -p -e
> 's,192.168.0.0\(,192.168.0.0/255.255.255.0\(,' /etc/exports  actually do? I
> issue the command and it just hangs. Does it change my exports file in some
> way?

Hmmm. The command worked for me.
It uses perl to do an in-place (-i) edit of /etc/exports which
changes every
   192.160.0.0(
to
   192.160.0.0/255.255.255.0(

Producing
/ 192.168.0.0/255.255.255.0(ro,no_root_squash)
/home/guest/share       192.168.0.0/255.255.255.0(ro,no_root,squash)
/home/guest/01            192.168.0.0/255.255.255.0(rw,no_root_squash)
/home/guest/02            192.168.0.0/255.255.255.0(rw,no_root_squash)
/home/guest/03            192.168.0.0/255.255.255.0(rw,no_root_squash)


As it was, the only filesystem that was exported to 192.168.*.* was /,
and it was exported read-only, just as you reported.

Note: this will only work if /home/guest/* are on a different
filesystem to /.  If they are on the same filesystem, you may as well
just export '/' rw.

NeilBrown

> 
> Thanks,
> 
> Nick
> 
> ----- Original Message -----
> From: "Neil Brown" <neilb@cse.unsw.edu.au>
> To: "Nicholas Lafferty" <nlafferty@pennswoods.net>
> Cc: "nfs" <nfs@lists.sourceforge.net>
> Sent: Wednesday, September 04, 2002 10:34 PM
> Subject: Re: [NFS] Can't mount nfs rw
> 
> 
> > On Wednesday September 4, nlafferty@pennswoods.net wrote:
> > > I'm having problems getting my diskless clients to mount NFS directories
> in
> > > Read-Write mode. I'm using bpbatch and tftp to transfer the kernel and a
> > > ramdisk for the root file system. I pass an initscript to the kernel
> that
> > > mounts the root file system of the server as read-only (mounts on /ro),
> > > /home/guest/share mounts as ro2 (read-only), and /home/guest/01 mounts
> as
> > > /rw (read-write). Then init is invoked. The problem is that all of the
> > > mounts are read-only.
> > >
> > > #Here is what my initscript does for the mounts.
> > > mount-t nfs -o nolock,ro,vers=2 $SERVER:/      /ro
> > > mount-t nfs -o nolock,ro,vers=2 $SERVER:/home/guest/share      /ro2
> > > mount-t nfs -o nolock,rw,vers=2 $SERVER:/home/guest/$ID      /rw
> > >
> > > /sbin/init '#'
> > >
> > > # Here is my /etc/exports
> > > /
> > > 192.168.0.0/255.255.255.0(ro,no_root_squash)
> > > /home/guest/share       192.168.0.0(ro,no_root,squash)
> > > /home/guest/01            192.168.0.0(rw,no_root_squash)
> > > /home/guest/02            192.168.0.0(rw,no_root_squash)
> > > /home/guest/03            192.168.0.0(rw,no_root_squash)
> > >
> > > Any suggestions on some other things to try?
> > >
> >
> >
> > perl -i -p -e 's,192.168.0.0\(,192.168.0.0/255.255.255.0\(,' /etc/exports
> >
> > NeilBrown
> >
> >
> > -------------------------------------------------------
> > This sf.net email is sponsored by: OSDN - Tired of that same old
> > cell phone?  Get a new here for FREE!
> > https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
