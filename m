From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 14:59:47 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
 <1110835899.19295.42.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
 <1110836857.24466.4.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxbQ-0003HP-M3
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:59:56 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxbP-0005cE-8u
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:59:56 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1110836857.24466.4.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, 14 Mar 2005, Trond Myklebust wrote:

> That was why I asked. If you update the binaries by copying into them (not
> renaming + creating new file), then strange things will happen: you will not
> see ESTALE, but you will usually see cache corruption.

hmmm.  i HAVE compiled these binaries and copied them up - but last week.
coud that make the cache so sick that it would not recover?

> The obvious and easy way to detect if this is the case, is to look at the
> ctime on the file in question.

then why should it corrupt the cache?  i mean - if it's easy to see why would
the nfs code see this and invalidate it's cache?  i understand this could only
happen based on validity of the inode cache - but this is stale ever 60
seconds (or something) so it seems this should sort it self out in time.  the
problem we are seeing persists forever until remount...

>>    * maybe the binaries core dump on startup
>>    * maybe it runs, but errors in strange ways
>>    * maybe it runs, but core dumps
>>    * sometimes it can be loaded into a debugger - sometimes not
>
> Have you looked at a hexdump of bad copy vs. good copy and done a diff?

not yet - we just noticed that the md5sums were actually different!

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
