From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: Re: rpc.mountd stops functioning
Date: Wed, 11 Aug 2004 11:02:06 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4119EE9E.8000509@framestore-cfc.com>
References: <411217BE.8070209@framestore-cfc.com> <20040805144659.GD25948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BupxN-0000Eg-Ms
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 03:03:41 -0700
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1BupxN-0006fU-3c
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 03:03:41 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040805144659.GD25948@fieldses.org>
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

J. Bruce Fields wrote:
> On Thu, Aug 05, 2004 at 12:19:26PM +0100, Johan van den Dorpe wrote:
> 
>>For a long time we've been experiencing problems with rpc.mountd 
>>stopping functioning.
> 
> 
> Maybe you need the following?
> 
> (Neil or someone, could you please apply this?  Last I checked it wasn't
> in nfs-utils cvs.)
> 
> --Bruce Fields
> 
> From Garrick Staples <garrick@usc.edu>:
> 
> After mountd handles a cache upcall, we should clear the relevant bits in the
> fd_set.

I've installed this patch and I'm testing it at the moment. It'll be 
some time before I can say whether this has worked.

So far, everythings been fine.

Thanks for your help,

-- 
Johan van den Dorpe


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
