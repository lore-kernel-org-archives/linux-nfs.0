From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 16:08:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ager0o$jjo$2@main.gmane.org>
References: <200207091549.15913.trond.myklebust@fys.uio.no>
	<Pine.LNX.3.95.1020709095544.27285A-100000@chaos.analogic.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Rvfj-0007Ws-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 07:08:56 -0700
To: root@chaos.analogic.com
In-Reply-To: <Pine.LNX.3.95.1020709095544.27285A-100000@chaos.analogic.com>
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

>>>>> " " == Richard B Johnson <root@chaos.analogic.com> writes:

     > I think code that opens a directory as a file is broken. We
     > have opendir() for that and it returns a DIR pointer, not a
     > file descriptor.  If the directory was properly opened, one
     > would never attempt to fsync() it.

 fsync() is supported on directories on local filesystems as a way of
ensuring that changes (due to file creation etc) are committed to
disk. Where is the POSIX violation in that?

 There is no reason why NFS, which ensures this anyway, should
not adhere to this convention.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
