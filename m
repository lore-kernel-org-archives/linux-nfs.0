From: Greg Banks <gnb@sgi.com>
Subject: Re: max filesystem size - nfs imposed limit?
Date: Thu, 20 May 2004 12:20:04 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040520022004.GE7316@sgi.com>
References: <1085010251.22480.52.camel@sabaki.dcs.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQdAR-0001pi-Nc
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 19:20:19 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQdAR-0006vp-Ez
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 19:20:19 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1085010251.22480.52.camel@sabaki.dcs.uci.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, May 19, 2004 at 04:44:11PM -0700, Dan Stromberg wrote:
> 
> We need to set up a multiterrabyte filesystem (probably 30T), and NFS
> export it.
> 
> Does linux nfs impose a maximum filesystem size? 

Yes, but if you use v3 or v4 it's larger than you care about.

> Or is that strictly a
> matter of the filesystem type being exported (ext3, xfs, lustre, gfs,
> whatever)?

That also matters.  You need to have a server OS which supports
large block devices, and the filesystem needs to support it also.
Obviously, XFS does (except it can't export more than 2^32 inodes
currently).

> Does it matter if you're using nfs v2/v3/v4? 

Yes.  Don't use NFSv2.

> Does the
> kernel version matter?  How about 32 bit vs 64 bit platforms (especially
> interested in whether an opteron or linux ppc would help)?

This comes down to large block device support.  You need to use 2.6
or apply the LBD patch to 2.4.

> Is linux NFS on 64 bit platforms stable?

Yes.  Our sales staff will be happy to sell you one, and as many TB
of disk as you can afford.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
