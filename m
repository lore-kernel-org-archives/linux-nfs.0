From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [NFS] htree+NFS (NFS client bug?)
Date: Thu, 28 Nov 2002 18:44:15 +0100
Sender: ext2-devel-admin@lists.sourceforge.net
Message-ID: <15846.21999.949270.354293@charged.uio.no>
References: <1038354285.1302.144.camel@sherkaner.pao.digeo.com>
	<shsptsrd761.fsf@charged.uio.no>
	<1038387522.31021.188.camel@ixodes.goop.org>
	<20021127150053.A2948@redhat.com>
	<15845.10815.450247.316196@charged.uio.no>
	<20021127205554.J2948@redhat.com>
	<20021128164439.E2362@redhat.com>
	<20021128171324.G2362@redhat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
    Ext2 devel <ext2-devel@lists.sourceforge.net>,
    NFS maillist <nfs@lists.sourceforge.net>,
    Linux Kernel List <linux-kernel@vger.kernel.org>
Return-path: <ext2-devel-admin@lists.sourceforge.net>
To: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <20021128171324.G2362@redhat.com>
Errors-To: ext2-devel-admin@lists.sourceforge.net
List-Help: <mailto:ext2-devel-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:ext2-devel@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=subscribe>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ext2-devel>,
	<mailto:ext2-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ext2-devel>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Stephen C Tweedie <sct@redhat.com> writes:

     > We're only using 31-bit hashes right now.  Trond, how will
     > other NFS clients react if we return an NFS cookie 32-bits
     > wide?  We could easily use something like 0x80000000 as an
     > f_pos to represent EOF in the Linux side of things, but will
     > that cookie work if passed over the wire on NFSv2?

For all other NFS clients that I know of, this is perfectly
acceptable. As far as the Linux kernel goes, it is quite OK, but when
you get to userland, glibc-2.2 and above will insist that this is an
illegal value (they like to sign extend 32-bit values). Causes no end
of trouble, since XFS tends to use '0xffffffff' as the EOF cookie.

I have a patch that hacks the values of such cookies so that glibc
will accept them. That hack will never go in to the official kernel,
so it would be nice if ext2/ext3 could avoid the need for it.

     > The alternative is to hack in a special case so that (for
     > example) we consider a major htree hash of 0x7fffffff to map to
     > an f_pos of 0x7ffffffe and just consider that a possible
     > collision, so that 0x7fffffff is a unique EOF for the htree
     > tree walker.

That would be fine.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
