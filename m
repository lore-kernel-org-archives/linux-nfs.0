From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4.21 - Oops in rpciod
Date: 14 Nov 2003 09:27:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs3ccr6n60.fsf@charged.uio.no>
References: <20031114121005.5dceb59a.philippe.gramoulle@mmania.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs <nfs@lists.sourceforge.net>,  linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKfAR-0005wu-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 06:43:23 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AKfAR-0001uS-Fb
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 06:43:23 -0800
To: Philippe Gramoull~ <philippe.gramoulle@mmania.com>
In-Reply-To: <20031114121005.5dceb59a.philippe.gramoulle@mmania.com>
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

>>>>> " " == Philippe Gramoull <Philippe> writes:

     >  Hi,

     > I happened to get this oops with a 2.4.21 (Dell 2650) running
     > as an NFS server.  The exported partition is ~ 700Gb/reiserfs
     > and was 99.99% full (only few dozens of megabytes left).
     > (Distro is Debian Sid/Unstable, RAID driver is megaraid.o v
     > 2.00.5)

Looks like something prematurely deleted the nlm_block. AFAICS that
can only happen if something is accessing the nlm_blocked list without
holding the BKL, or is failing to respect the b_incall flag.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
