From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 09:41:46 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040226084146.GA1197@suse.de>
References: <20040225022210.51884.qmail@web12821.mail.yahoo.com> <403D692D.33C4D7E8@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Shantanu Goel <sgoel01@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwH7J-0006pX-W3
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 00:43:37 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AwH5Z-00087A-VU
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 00:41:50 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <403D692D.33C4D7E8@melbourne.sgi.com>
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

On Thu, Feb 26, 2004 at 02:34:05PM +1100, Greg Banks wrote:
> change the allocation algorithm of rpc_rqsts to divide the
> RPC_MAXREQS space into three fixed spaces by class: sync calls,
> async (writes & commits), and all other async calls.  Attempts to

I don't think this is a good solution for UDP. If you bump the number
of slots at the same time, you may still end up with the same symptoms,
as your async write requests may eat your congestion window, leaving just
the crumbs for sync requests. If you don't bump the number of slots,
write throughput will suffer.

What about modifying __rpc_sleep_on to put sync tasks always
at the head of the queue? This way sync tasks get priority when
it comes to call reservation.

(for fairness reasons, you may want to walk the queue and insert
your sync task before the first async task at least)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
