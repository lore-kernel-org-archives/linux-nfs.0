From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Will NFSv4 be accepted?
Date: Fri, 16 Aug 2002 01:07:36 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40672.5444984206$1029453194@news.gmane.org>
References: <Pine.LNX.4.44.0208141938350.31203-100000@mooru.gurulabs.com>
	<Pine.LNX.4.44.0208151027510.3130-100000@home.transmeta.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dax Kelson <dax@gurulabs.com>,
    Alan Cox <alan@lxorguk.ukuu.org.uk>,
    "Kendrick M. Smith" <kmsmith@umich.edu>,
    "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
    "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>,
    <beepy@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17fTjA-0006f4-00
	for <nfs@lists.sourceforge.net>; Thu, 15 Aug 2002 16:08:29 -0700
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0208151027510.3130-100000@home.transmeta.com>
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

>>>>> " " == Linus Torvalds <torvalds@transmeta.com> writes:

     > I personally doubt that NFS would be the thing driving
     > this. Judging by past performance, NFS security issues don't
     > seem to bother people. I'd personally assume that the thing
     > that would be important enough to people for vendors to add it
     > is VPN or encrypted (local) disks.

As I said: one of the main motivations for NFSv4 is WAN support, and
in those environments, strong authentication is a must.

That said, the plan is to also prepare a 'null' authentication scheme
for RPCSEC_GSS (basically using RPCSEC_GSS as a wrapper for AUTH_UNIX)
so that the strong auth can be provided as a simple plugin in case its
inclusion in the kernel would not be acceptable.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
