From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 17:57:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040811175758.A30274@infradead.org>
References: <4119FB15.7010205@stams.strath.ac.uk> <411A17F2.2060203@RedHat.com> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Thurlbeck <ian@stams.strath.ac.uk>,
	Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuwQb-00044Y-Gj
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:58:17 -0700
Received: from imladris.demon.co.uk ([193.237.130.41] helo=phoenix.infradead.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BuwQa-0008RN-Sg
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:58:17 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040811164135.GA11101@suse.de>; from okir@suse.de on Wed, Aug 11, 2004 at 06:41:35PM +0200
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

On Wed, Aug 11, 2004 at 06:41:35PM +0200, Olaf Kirch wrote:
> I've been thinking about this a little more. It may be that one reason
> the problem is more pronounced in in 2.6 than in 2.4 is the new io
> barrier code.

2.6 mainline doesn't have barrier support.



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
