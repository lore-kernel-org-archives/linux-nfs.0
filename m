From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 19:22:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16308.8254.89284.377113@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
	<shssmkttk34.fsf@charged.uio.no>
	<3FB29D43.A618973D@psu.edu>
	<16306.41898.291062.36209@charged.uio.no>
	<3FB2A738.3F2C90B8@psu.edu>
	<16306.49310.195265.145519@charged.uio.no>
	<3FB2DC60.FA7D3E08@psu.edu>
	<16306.59249.857512.354675@charged.uio.no>
	<3FB3924B.7450E9F7@psu.edu>
	<3FB3FDE8.47E819FF@psu.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKRjJ-0002lo-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 16:22:29 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKRjJ-0002d1-65
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 16:22:29 -0800
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <3FB3FDE8.47E819FF@psu.edu>
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

>>>>> " " == Jason Holmes <jholmes@psu.edu> writes:

     > if you want to look at them.  One small observation is that
     > 2.4.22 reaches much larger values of cwnd than test9-bk17,
     > resulting in a lot fewer calls to functions such as
     > xprt_cwnd_limited (1861 vs. 2715). Whether or not this means
     > anything, I don't know.

It means that the UDP throughput is slightly more stable. However the
thing that surprises me there is that in both cases 'xprt_cwnd_limited
cong = 0' is the dominant case. That means basically that you only
have one outstanding request on the wire at any point in time (there
are only a few cases where cong=256 => 2 requests, and cong=512 => 3
requests).

IOW this all appears to be doing synchronous I/O only (both in the
case of 2.4.22 and 2.6.0).
Note: most of these RPC calls do indeed appear to be something other
than WRITE calls. Are they perhaps GETATTR calls? Have you for
instance set 'noac', 'actimeo' or something like that?


Could you please try using

echo "9" >/proc/sys/sunrpc/nfs_debug

rather than echo "1". That should give us the debugging info from
nfs/read.c and nfs/write.c in addition to what you've already got.


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
