From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 20:18:53 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402261951540.29459-100000@kenzo.iwr.uni-heidelberg.de>
References: <482A3FA0050D21419C269D13989C611302B07B91@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Olaf Kirch <okir@suse.de>, <trond.myklebust@fys.uio.no>,
        Greg Banks <gnb@melbourne.sgi.com>, ShantanuGoel <sgoel01@yahoo.com>,
        <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwR4F-0002W7-Um
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 11:21:07 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwQoH-00056R-3R
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 11:04:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07B91@lavender-fe.eng.netapp.com>
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

On Thu, 26 Feb 2004, Lever, Charles wrote:

> 1 and 3 are usually a bounded number of writes and fairly urgent,

Well, the default these days is "sync", so 3 becomes less bounded, as 
you can still do the "dd" write storm. Also if some process is started 
and wants to allocate lots of memory, even 1 can trigger a large 
amount of writes.

> perhaps the RPC client should have a two- (or more) level scheduler
> queue. place the requests that have to go now on the top queue, and
> the readahead/writebehind tasks on the bottom.

That was exactly what I had in mind, except that my mind considered 
sync=urgent; with your detailed op types, it makes sense to order by 
"urgency" rather than sync/async.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De






-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
