From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux NFS client hangs when it read a large file
Date: 19 Apr 2002 14:13:05 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3cxrnay6.fsf@charged.uio.no>
References: <20020419111618.19A3770023@sv1.valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yXGT-0002LI-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Apr 2002 05:13:22 -0700
To: Hirotaka Sasaki <sasaki@valinux.co.jp>
In-Reply-To: <20020419111618.19A3770023@sv1.valinux.co.jp>
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

>>>>> " " == Hirotaka Sasaki <sasaki@valinux.co.jp> writes:

     > Hi, I'm having trouble with the Linux NFS client.

     > NFS Server is Redhat 7.2 with Linux-2.4.17+XFS-1.0.2.  NFS
     > Client is Redhat 7.2 with Linux-2.4.17.

     > On the NFS Server, I'm exporting a XFS file system under an
     > arbitrary directory name.

     > Next, I mount that file system using the NFS client via
     > NFSv3/UDP.

     > For Linux 2.4, the maximum accessible file offset of XFS is
     > 16TB(0xffffffff000) on 4K page size.

     > I can read a file with an offset of 0xfffffff8000, but the
     > client hangs when I read a file with an offset of 0xfffffff9000
     > from the server on the client.

Actually, you are not even supposed to be able to read the offset of
0xfffffff8000. The maximum offset supported by any 32-bit Linux system
is

MAX_LFS_FILESIZE == (((u64)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)

For i386 that works out as
MAX_LFS_FILESIZE == ((1 << 12) << 31) - 1 == 2^43 - 1
                 == 0x7ffffffffff

The ability to read beyond is an NFS bug which was fixed in the
2.4.19-preX series...

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
