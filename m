From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Input/output error on hard mounted NFS directory
Date: 14 May 2002 12:51:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shselgff1dd.fsf@charged.uio.no>
References: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Zuc-0005nl-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 03:52:10 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.30.0205141159580.28229-100000@elin.scali.no>
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

>>>>> " " == Steffen Persvold <sp@scali.com> writes:

     > I'm compiling up a large project which resides on a NFS mounted
     > ext2 filesystem. In this case the NFS server is running RH 7.2
     > kernel-smp-2.4.9-21 (i686 version) nfs-utils-0.3.1-13.7.2.1,
     > and the client is running RH 6.2 kernel-enterprise-2.2.19-6.2.7
     > (i686 version).

If you want to run a 2.2. client, then grab 2.2.21-rc2, and apply the
patch from

  http://www.fys.uio.no/~trondmy/src/2.2.21-rc2/linux-2.2.21-NFS.dif

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
