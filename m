From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: e1000 intel driver bug (which impacts nfs)
Date: 03 Jun 2002 09:48:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shselfo7qgx.fsf@charged.uio.no>
References: <Pine.OSF.4.20.0205262256430.16951-100000@azure.dstc.edu.au>
	<20020603002819.A5501@stud.ntnu.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17EmZs-0005iS-00
	for <nfs@lists.sourceforge.net>; Mon, 03 Jun 2002 00:48:32 -0700
Received: from charged.uio.no ([129.240.86.49])
	by pat.uio.no with esmtp (Exim 2.12 #7)
	id 17EmZf-000526-00
	for nfs@lists.sourceforge.net; Mon, 3 Jun 2002 09:48:19 +0200
Received: from trondmy by charged.uio.no with local (Exim 2.12 #1)
	id 17EmZa-0001zF-00
	for nfs@lists.sourceforge.net; Mon, 3 Jun 2002 09:48:14 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <20020603002819.A5501@stud.ntnu.no>
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

     > We've also got problems with nfs-hangs when transfering large
     > files (ie.  files around 300-400M, sometime we have to go a bit
     > higher tho, like 2GB-3GB files, but it's always possible to
     > trigger this. However, we don't need to be jumping through
     > hoops to "fix it", after a min or so, it's ok again. It seems
     > to me like there's a VM problem or something.

     > We've got 2GB mem on the machines which are suffering from
     > theese problems.

There is a problem with highmem that I'm just barely getting to grips
with: NFS is able to starve the kernel of highmem bounce buffer
resources because we kmap() the pages for too long (surprise: NFS
predates the highmem code by several years and so nobody ever
considered kmap() when the design was made).

An attempt at a fix has been merged in to the development kernels as
of 2.5.19. The same patches are available for 2.4.19-pre8 +
NFS_ALL. If you'd like to test it out, you will need

http://www.fys.uio.no/~trondmy/src/2.4.19-pre8/linux-2.4.19-NFS_ALL.dif

+ the 4 patches from

http://www.fys.uio.no/~trondmy/src/2.4.19-pre8/alpha

Cheers,
   Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
