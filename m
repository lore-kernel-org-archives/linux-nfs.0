From: Thomas =?iso-8859-1?Q?Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: RedHat Rawhide Kernels
Date: Fri, 9 Aug 2002 03:04:32 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020809010432.GA12851@stud.ntnu.no>
References: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk> <20020808153331.F28223@redhat.com> <shs65ylm7hp.fsf@charged.uio.no> <20020808162326.G28223@redhat.com> <15698.54589.795037.127176@charged.uio.no> <20020808165712.H28223@redhat.com> <15698.57249.605357.32060@charged.uio.no> <20020808172729.J28223@redhat.com> <shshei511bu.fsf@charged.uio.no>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from due.stud.ntnu.no ([129.241.56.71])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cyCk-0005pK-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 18:04:39 -0700
Received: from localhost (localhost [127.0.0.1])
	by due.stud.ntnu.no (Postfix) with ESMTP id E545312B49C
	for <nfs@lists.sourceforge.net>; Fri,  9 Aug 2002 03:04:33 +0200 (CEST)
Received: from ozelot.stud.ntnu.no (ozelot.stud.ntnu.no [129.241.56.185])
	by due.stud.ntnu.no (Postfix) with ESMTP id 2467312B48A
	for <nfs@lists.sourceforge.net>; Fri,  9 Aug 2002 03:04:33 +0200 (CEST)
Received: (from tlan@localhost)
	by ozelot.stud.ntnu.no (8.11.6/8.10.0.Beta12) id g7914Xt13415
	for nfs@lists.sourceforge.net; Fri, 9 Aug 2002 03:04:33 +0200
To: NFS maillist <nfs@lists.sourceforge.net>
In-Reply-To: <shshei511bu.fsf@charged.uio.no>
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

Trond Myklebust:
> The only other hang I can think of concerns only HIGHMEM machines,
> where you can deadlock while exhausting all free kmap() resources.
> Also fixed (well - at least chances are *very* heavily reduced) in the
> new 'kmap' patchsets.

Is this included in 2.4.19 or won't we see it before 2.4.20 comes along?

-- 
Thomas


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
