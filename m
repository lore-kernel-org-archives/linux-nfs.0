From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Wed, 12 Nov 2003 18:22:06 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16306.49310.195265.145519@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
	<shssmkttk34.fsf@charged.uio.no>
	<3FB29D43.A618973D@psu.edu>
	<16306.41898.291062.36209@charged.uio.no>
	<3FB2A738.3F2C90B8@psu.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AK4JW-0006oe-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 15:22:18 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AK4JV-0007D7-ID
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 15:22:17 -0800
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <3FB2A738.3F2C90B8@psu.edu>
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

     > I wasn't, but I'm recompiling test9-bk17 with all of the
     > debugging options turned on right now.  Is there anything in
     > particular you want me to do?

Come to think of it, could you try running with and without the patch
on

  http://www.fys.uio.no/~trondmy/src/Linux-2.6.x/2.6.0-test9/linux-2.6.0-01-fix_deadlock.dif

That fixes a race that is likely to show up when memory is
low. Normally it should cause a deadlock rather than corruption, but
it is conceivable that there are other side-effects...

Please make sure that you run with slab debugging enabled...

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
