From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Sun, 26 May 2002 00:13:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15600.3208.451267.839751@charged.uio.no>
References: <200205141437.26169.trond.myklebust@fys.uio.no>
	<Pine.LNX.4.33.0205241316260.3144-100000@sp-home.isdn.scali.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BjnG-0004tw-00
	for <nfs@lists.sourceforge.net>; Sat, 25 May 2002 15:13:46 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.33.0205241316260.3144-100000@sp-home.isdn.scali.no>
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

     > Can you give me any more details to why it helped upgrading my
     > NFS server to 2.4.18 ?

See the linux-kernel and NFS@sourceforge archives. Those races were
discovered by the 'fsx' filesystem exerciser.

Cheers,
  Trond

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
