From: Olaf Kirch <okir@suse.de>
Subject: Re: file system read locks
Date: Fri, 20 Aug 2004 17:39:21 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040820153921.GB6861@suse.de>
References: <Pine.LNX.4.60.0408200907020.6148@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByBUD-0003eN-8u
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 08:39:25 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1ByBUC-0002T9-M1
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 08:39:25 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0408200907020.6148@harp.ngdc.noaa.gov>
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

On Fri, Aug 20, 2004 at 09:08:15AM -0600, Ara.T.Howard wrote:
> i have a perfectly functioning filesystem based write lock algorithim
> (link(2)).

Except that these FS based approaches don't support blocking; you
always have to poll.

> has anyone out there come up with an algorithim to make __read__
> locks using file system primitives?

Take a directory X. If the directory exists and is empty, the lock is not
taken by anyone. To take a read lock, create a file in that directory.
To take a write lock, remove the directory.

(This scheme has the drawback that it's highly unfair to writers, but you
can probably make it favor writers if you start to move it around rather
than rmdir it)

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
