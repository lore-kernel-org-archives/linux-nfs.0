From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Corrupt Data when using NFS on Linux
Date: 29 Oct 2002 16:36:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsptttqmti.fsf@charged.uio.no>
References: <D38AFB3080F3D311807300B0D0203E53033A92EA@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 186YPx-0003bI-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Oct 2002 07:36:33 -0800
To: pwitting@Cyveillance.com
In-Reply-To: <D38AFB3080F3D311807300B0D0203E53033A92EA@MERCURY>
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

>>>>> " " == pwitting  <pwitting@Cyveillance.com> writes:

     > I'm curious now. Is this issue really in the linux kernel or is
     > this actually a Filesystem issue? It would seem to be a
     > filesystem issue, specifically how the FS chose to store the
     > mtime, which could allow a different FS (say, a non-linux fs
     > such as jfs or xfs) to solve the problem.

The problem is that Linux lacks support for >32-bit mtimes in the VFS
layer. Even if the underlying filesystem is capable of supporting a
64-bit mtime, the kernel structures are only seeing the high 32 bits.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
