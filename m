From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [Acl-Devel] NFSv3 ACL status?
Date: Thu, 12 Aug 2004 15:49:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092318594.31293.7.camel@winden.suse.de>
References: <Pine.LNX.4.44.0408120858530.14721-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, acl-devel@bestbits.at
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvFxx-0005vG-JR
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 06:50:01 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BvFxu-0007Hh-4A
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 06:49:58 -0700
To: Peter Astrand <peter@cendio.se>
In-Reply-To: <Pine.LNX.4.44.0408120858530.14721-100000@maggie.lkpg.cendio.se>
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

On Thu, 2004-08-12 at 09:01, Peter Astrand wrote:
> Can someone give an quick overview of the Linux NFSv3 ACL status? The
> Linux NFS FAQ at http://nfs.sourceforge.net/ says:
> 
> "D3. What does this mean:  svc: unknown program 100227 (me 100003)
> 
> A. It refers to a mount request by a Solaris system that is trying to get
> ACL information - which linux obviously does not have. "
> 
> But: http://acl.bestbits.at/ seems to indicate that ACLs over NFSv3
> actually works, and provides patches for 2.6.1, but I can't find any
> information about if this patch is really needed for modern kernels
> (2.6.7) or modern distributions. Is this patch for the server, client or 
> both?

The patch is required on both the client and the server side. (You will
find a more recent version of the patch as part of
ftp://ftp.suse.com/pub/people/mantel/kotd/i386/kernel-source.src.rpm.)

> Also, what about interoperatbility with Solaris?

The implementation is compatible.

Cheers,
-- 
Andreas Gruenbacher <agruen@suse.de>
SUSE Labs, SUSE LINUX AG




-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
