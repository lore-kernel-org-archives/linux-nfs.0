From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File corruption linux 2.4 nfs client to freebsd server
Date: Wed, 19 Nov 2003 13:45:16 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16315.47676.38292.14173@charged.uio.no>
References: <1069235928.1215.79.camel@krypton.medical-insight.com>
	<shs8ymcs72u.fsf@charged.uio.no>
	<1069260099.2348.14.camel@krypton.medical-insight.com>
	<16315.43986.994562.15500@charged.uio.no>
	<1069265236.3fbbb154c8170@webmail.medical-insight.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMXKN-00037a-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 10:45:23 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AMXKN-0006Nu-14
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 10:45:23 -0800
To: Morten Olsen <mso@medical-insight.com>
In-Reply-To: <1069265236.3fbbb154c8170@webmail.medical-insight.com>
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

>>>>> " " == Morten Olsen <mso@medical-insight.com> writes:

     > 0x27a7b to 0x35bd2 25401(57 mod 256): MAPWRITE 0x27a6a thru
     > 0x29c1d (0x21b4 bytes) 25402(58 mod 256): TRUNCATE UP from
     > 0x35bd2 to 0x3ffff 25403(59 mod 256): MAPWRITE 0x1aac thru
     > 0xf308 (0xd85d bytes) 25404(60 mod 256): READ 0x3138b thru
     > 0x3561c (0x4292 bytes) 25405(61 mod 256): MAPREAD 0x25daa thru
     > 0x32ef9 (0xd150 bytes) 25406(62 mod 256): READ 0x3064b thru
     > 0x33366 (0x2d1c bytes) 25407(63 mod 256): READ 0x3f973 thru
     > 0x3fffe (0x68c bytes)

I strongly suspect a server bug. This one looks so obvious that I
would have caught it on my own testrigs.

Just to make sure, though, could you please send me a tcpdump of those
last few seconds when doing fsx? A binary dump, with snaplen=9000.

   tcpdump -w dump.out -s 9000 host freebsd.server and port 2049

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
