From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH 2.6.3] Add write throttling to NFS client
Date: Thu, 26 Feb 2004 17:24:58 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402261717080.28943-100000@kenzo.iwr.uni-heidelberg.de>
References: <20040226145051.GE32597@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, Greg Banks <gnb@melbourne.sgi.com>,
        ShantanuGoel <sgoel01@yahoo.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwOLl-000853-3s
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 08:27:01 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwOJr-0004be-3S
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 08:25:03 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040226145051.GE32597@suse.de>
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

On Thu, 26 Feb 2004, Olaf Kirch wrote:

> The general "unfairness" observed in writes is due to the fact that we
> allow a writing process to dirty a large number of pages without blocking
> for the actual IO.

Yes, and I think that this is pretty similar to the situation 
encountered with block IO, where queued writes had to be serviced 
before later queued reads, giving an impression of unresponsivness. 
It's easier to accept a delayed write than a delayed read.

> Applications doing lots of stats etc are punished so severely because
> all these operations are synchronous.

That's exactly the case for block IO reads.

> BTW I think reading is much less of a problem. The number of readaheads
> scheduled by generic_file_read is limited,

On the other hand, based on the block IO experience, reads should have 
higher priority than writes :-)

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
