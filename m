From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS utils package, and an fsx question
Date: 13 May 2002 07:35:10 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr8kgd301.fsf@charged.uio.no>
References: <3CDF247A.E7106AA4@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1778UU-0007mr-00
	for <nfs@lists.sourceforge.net>; Sun, 12 May 2002 22:35:22 -0700
To: Tom McNeal <trmcneal@attbi.com>
In-Reply-To: <3CDF247A.E7106AA4@attbi.com>
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

>>>>> " " == Tom McNeal <trmcneal@attbi.com> writes:

     > The tests consist of the 4 2002 Connectathon tests suites
     > (basic, general, special, and lock), fsx, a duplicate request
     > cache exerciser, and bonnie++, all running simultaneously
     > overnight.  I tested a 2.4.18 and 2.2.19 UP client against
     > 2.4 and 2.2 UP servers.  The failure rate was less than 1%,
     > primarily due to interaction between special and general tests
     > that I haven't quite figured out yet.

Any details on the failures? 2.4.18 was tested extensively at Cthon
with no problems being observed...

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
