From: Morten Olsen <mso@medical-insight.com>
Subject: Re: File corruption linux 2.4 nfs client to freebsd server
Date: Wed, 19 Nov 2003 19:07:16 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1069265236.3fbbb154c8170@webmail.medical-insight.com>
References: <1069235928.1215.79.camel@krypton.medical-insight.com> <shs8ymcs72u.fsf@charged.uio.no> <1069260099.2348.14.camel@krypton.medical-insight.com> <16315.43986.994562.15500@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMWjX-0006pj-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 10:07:19 -0800
Received: from [62.242.251.241] (helo=arsenium.medical-insight.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMWjW-0001i9-Ia
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 10:07:18 -0800
To: "" <trond.myklebust@fys.uio.no>
In-Reply-To: <16315.43986.994562.15500@charged.uio.no>
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

Quoting Trond Myklebust <trond.myklebust@fys.uio.no>:

> >>>>> " " == Morten Sylvest Olsen <mso@medical-insight.com> writes:
> 
>      > I can reproduce the problem on the clients using fsx. The error
>      > occurs after 25407 fsx operations with an I/O error, with no
>      > difference between test file and fsxgood file. (default options
>      > to fsx)
> 
> Could you show us the output of the last 20 lines or so from the fsx
> logfile? As I said, I'd like to know which operation is failing.

It fails in read:

..
truncating to largest ever: 0x3ff9d
truncating to largest ever: 0x3ffff
doread: read: Input/output error
LOG DUMP (25407 total operations):
25408(64 mod 256): MAPREAD      0x324b6 thru 0x346b4    (0x21ff bytes)
25409(65 mod 256): WRITE        0x24755 thru 0x2bd12    (0x75be bytes)
25410(66 mod 256): TRUNCATE DOWN        from 0x40000 to 0x3a9da
..
..
25397(53 mod 256): MAPWRITE 0x1bdd0 thru 0x22566        (0x6797 bytes)
25398(54 mod 256): WRITE        0xc250 thru 0xdf81      (0x1d32 bytes)
25399(55 mod 256): READ 0x4623 thru 0xccbb      (0x8699 bytes)
25400(56 mod 256): TRUNCATE UP  from 0x27a7b to 0x35bd2
25401(57 mod 256): MAPWRITE 0x27a6a thru 0x29c1d        (0x21b4 bytes)
25402(58 mod 256): TRUNCATE UP  from 0x35bd2 to 0x3ffff
25403(59 mod 256): MAPWRITE 0x1aac thru 0xf308  (0xd85d bytes)
25404(60 mod 256): READ 0x3138b thru 0x3561c    (0x4292 bytes)
25405(61 mod 256): MAPREAD      0x25daa thru 0x32ef9    (0xd150 bytes)
25406(62 mod 256): READ 0x3064b thru 0x33366    (0x2d1c bytes)
25407(63 mod 256): READ 0x3f973 thru 0x3fffe    (0x68c bytes)

- Morten




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
