From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RedHat Rawhide Kernels
Date: 09 Aug 2002 06:51:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsznvwfxe1.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
	<20020808153331.F28223@redhat.com> <shs65ylm7hp.fsf@charged.uio.no>
	<20020808162326.G28223@redhat.com>
	<15698.54589.795037.127176@charged.uio.no>
	<20020808165712.H28223@redhat.com>
	<15698.57249.605357.32060@charged.uio.no>
	<20020808172729.J28223@redhat.com> <shshei511bu.fsf@charged.uio.no>
	<20020809010432.GA12851@stud.ntnu.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17d1k1-0005bt-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 21:51:13 -0700
Received: from charged.uio.no ([129.240.86.49])
	by mons.uio.no with esmtp (Exim 2.12 #7)
	id 17d1js-0004db-00
	for nfs@lists.sourceforge.net; Fri, 9 Aug 2002 06:51:04 +0200
Received: from trondmy by charged.uio.no with local (Exim 2.12 #1)
	id 17d1jr-0001Qy-00
	for nfs@lists.sourceforge.net; Fri, 9 Aug 2002 06:51:03 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020809010432.GA12851@stud.ntnu.no>
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

>>>>> " " =3D=3D Thomas Lang=E5s <tlan@stud.ntnu.no> writes:

     > Trond Myklebust:
    >> The only other hang I can think of concerns only HIGHMEM
    >> machines, where you can deadlock while exhausting all free
    >> kmap() resources.  Also fixed (well - at least chances are
    >> *very* heavily reduced) in the new 'kmap' patchsets.

     > Is this included in 2.4.19 or won't we see it before 2.4.20
     > comes along?

You can see it in 2.5.x or from my patchsets for 2.4.19 (in the usual
place).

Cheers,
   Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
