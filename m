From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: bad cookie size 20 (only cookies under 8 bytes are supported.)
Date: Wed, 05 Nov 2003 14:54:32 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FA87478.BE1069F9@melbourne.sgi.com>
References: <3FA512B2.1080109@inf.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AHEko-0006wb-00
	for <nfs@lists.sourceforge.net>; Tue, 04 Nov 2003 19:54:46 -0800
Received: from zok.sgi.com ([204.94.215.101])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AHEkl-0007AD-8a
	for nfs@lists.sourceforge.net; Tue, 04 Nov 2003 19:54:43 -0800
To: Marc Schmitt <mschmitt@inf.ethz.ch>
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

Marc Schmitt wrote:
> 
> Hi all,
> 
> I did upgrade yesterday my RedHat 7.3 box (2.4.20-20.7smp) from
> nfs-utils 1.0.5 to 1.0.6, after that, messages was full with:
> 
> Nov  2 15:02:56 server kernel: lockd: bad cookie size 20 (only cookies
> under 8 bytes are supported.)
> Nov  2 15:02:56 server kernel: svc: failed to decode args
> Nov  2 15:02:57 server kernel: lockd: bad cookie size 20 (only cookies
> under 8 bytes are supported.)
> Nov  2 15:02:57 server kernel: svc: failed to decode args
> Nov  2 15:03:16 server kernel: lockd: bad cookie size 20 (only cookies
> under 8 bytes are supported.)
> 
> I've never had those messages before, does 1.0.6 require a certain
> minimum kernel version (ex. >= 2.4.22)?

I sent Trond a patch to fix this in March.  It's not your nfs-utils,
somebody on the network started a MacOS X 10.3 NFS client.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
