From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: IRIX NFS server and Linux NFS client
Date: 11 Apr 2002 14:09:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs662yjv2l.fsf@charged.uio.no>
References: <Pine.LNX.4.30.0204111218440.30970-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>,  <linux-kernel@vger.kernel.org>,
	  <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vdOT-00017W-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Apr 2002 05:09:38 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.30.0204111218440.30970-100000@elin.scali.no>
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

     > I forgot to mention that NFSv3 works when an IRIX client mounts
     > the same directory (i.e the directory shows up as "nfs" and not
     > "nfs2" in the mount table on the IRIX client).

     > Could it be that IRIX only supports NFSv3 with TCP and not UDP
     > (I didn't try TCP mounting on the Linux client) ?

Have you applied

  http://www.fys.uio.no/~trondmy/src/2.4.18/linux-2.4.18-seekdir.dif

in order to work around the glibc-2.x readdir bugs?

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
