From: Jani Averbach <jaa@jaa.iki.fi>
Subject: Re: [BUG] 2.6.8-rc4 + nfsd: Unable to handle kernel NULL pointer dereference
Date: Fri, 13 Aug 2004 02:49:25 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040813084925.GB32678@jaa.iki.fi>
References: <20040813025704.GA32305@jaa.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvXkc-00025G-4z
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 01:49:26 -0700
Received: from dsl081-100-231.den1.dsl.speakeasy.net ([64.81.100.231] helo=hal9000.jaa.iki.fi)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BvXkb-0000fA-QP
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 01:49:26 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040813025704.GA32305@jaa.iki.fi>
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

On 2004-08-12 20:57-0600, Jani Averbach wrote:
> 
> I narrowed this down to the 2.6.8rc4, 2.6.8rc3 works ok. And this
> happens (on server) every time, when thin client tried mount root-fs
> from server.

This happens elsewhere also, please see lkml post:
http://marc.theaimsgroup.com/?l=linux-kernel&m=109238419223996&w=4

In my case the version of client kernel is 2.6.7.

BR, Jani

-- 
Jani Averbach



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
