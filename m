From: Olaf Kirch <okir@suse.de>
Subject: Re: kernel nlockmgr not registred with port mapper
Date: Fri, 13 Aug 2004 18:32:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040813163223.GA10834@suse.de>
References: <411C91BA.10506@naturalsciences.be> <1092413690.5046.20.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Libert <Paul.Libert@naturalsciences.be>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bveyl-0001le-Ka
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:32:31 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Bveyl-0006lO-7F
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 09:32:31 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092413690.5046.20.camel@lade.trondhjem.org>
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

On Fri, Aug 13, 2004 at 12:14:51PM -0400, Trond Myklebust wrote:
> Looks to me as if you are using the user space NFS server. That never
> had any support for the NLM locking protocol. In fact IIRC the addition
> of locking support was one of the main motivations at the time for
> writing the kernel NFS server (correct me if I'm wrong there Olaf).

That's right. Doing lockd in user space is horrible.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
