From: James Pearson <james-p@moving-picture.com>
Subject: Re: getcwd() returns wrong pathname
Date: Tue, 03 Dec 2002 10:16:08 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3DEC8468.64E04028@moving-picture.com>
References: <20021203114545W.miyoshi@hpc.bs1.fc.nec.co.jp>
		<15852.9815.372469.298167@notabene.cse.unsw.edu.au>
		<20021203134704L.miyoshi@hpc.bs1.fc.nec.co.jp> <15852.17440.790970.70154@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, tanaka-h@mxm.nes.nec.co.jp,
 	hoshi@bsd.tnes.nec.co.jp, yamasita@hpc.necst.nec.co.jp,
 	fuku@hpc.bs1.fc.nec.co.jp, lgml@linuxdb.hpc.bs1.fc.nec.co.jp
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JA71-0005eY-00
	for <nfs@lists.sourceforge.net>; Tue, 03 Dec 2002 02:17:07 -0800
To: miyoshi@hpc.bs1.fc.nec.co.jp
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

IRIX clients used to suffer in a similar way - a couple of
workarounds/patches for the Linux knfsd server are suggested in the NFS
HOW-TO at:

http://nfs.sourceforge.net/nfs-howto/interop.html#IRIX

Unfortunately the links mentioned are out-of-date - should now be:

 http://oss.sgi.com/projects/xfs/mail_archive/200110/msg00006.html

 http://marc.theaimsgroup.com/?l=linux-nfs&m=99743544531724&w=2
 
I understand these patches work for HP-UX clients as well.

James Pearson

Neil Brown wrote:
> 
> On Tuesday December 3, miyoshi@hpc.bs1.fc.nec.co.jp wrote:
> >
> > Hi,
> >
> > > > I'm having problems with linux NFS. Here is my situation.
> > > >
> > > > When mounting remote linux NFS filesystem to /mnt/xxx/yyy,
> > > > pwd or getcwd() sometimes returns imcomplete pathname.
> > > > We are using linux kernel 2.4.17.
> > > >
> > > > % mount linuxserver:/mnt/xxx /mnt/xxx
> > > > % cd /mnt/xxx/yyy
> > > > % pwd
> > > > /xxx/yyy       <--- should be /mnt/xxx/yyy
> > > >
> > > > Is there any ideas or fixes?
> > > > I'll be very gratefull to any suggestion.
> > >
> > > Are both client and server Linux?
> >
> > Thank you for your response and sorry for not providing enough
> > information.
> >
> > Server is Linux, but client is not linux (NEC enhanced UNIX and HP-UX)
> > Also I found bugzilla entry which says about same problem on IRIX.
> >
> > http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=46705
> >
> > It may be a problem or an incompatibility of those unices,
> > but if it is a typical incompatibility, I want to know the root
> > cause of it.
> 
> The root cause is that pwd works but walking up a path of ..,
> ../.. etc finding the name of each component by reading through the
> directory for a name which matches the inode number found by statting
> ".." from below (does that make sense?)
> 
> Anyway, this requires '..' to work reliably, particularly over the
> mount point.
> 
> On non-linux unixes, the client sends a 'lookup("..")' request to the
> fileserver. In order for the client to recognise the mount point on
> the way up a path of ".." lookups, the filehandle returned by
> lookup(".."),  but be exactly the filehandle that was obtained by the
> mount request.
> 
> However, HP-UX (At least) does this comparison wrongly.  In NFSv3,
> filehandles are variable length, up to 64 bytes.  HP-UX however will
> always compare at least 32 bytes (the size of an NFSv2 filehandle).
> If the filehandle returned by the server is less than 32 bytes (which
> is the case with the Linux nfs server) then some of those 32 bytes
> compared will be random garbage, and the comparison will fail.  So pwd
> never finds the mountpoint as it walks up the chain of "..", and gets
> confused.
> 
> Apparently HP were going to release a fix for this, but I don't know
> if they have.
> 
> One work-around is to use NFSv2.  It uses fixed sized (zero-padded)
> filehandles and so doesn't suffer this problem.
> 
> It is possible to hack the Linux nfs server to return a minimum
> filehandle of 32 bytes, but I don't want that hack in the standard
> kernel.
> 
> NeilBrown
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Get the new Palm Tungsten T
> handheld. Power & Color in a compact size!
> http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
