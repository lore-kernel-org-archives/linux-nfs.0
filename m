From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 13/16] pnfs: wave 3: filelayout i/o helpers
Date: Tue, 15 Feb 2011 10:12:18 -0500
Message-ID: <B64DC183-76F0-406F-B48D-05D7F50BA43D@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com> <1297711116-3139-14-git-send-email-andros@netapp.com> <20110215093113.GC29871@infradead.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org,
	Fred Isaman <iisaman@netapp.com>,
	Andy Adamson <andros@citi.umich.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Marc Eshel <eshel@almaden.ibm.com>,
	Mike Sager <sager@netapp.com>,
	Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>,
	Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	Tigran Mkrtchyan <tigran-AxwfgvFle7WHvArXmyJukw@public.gmane.org>,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
	Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4911 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755113Ab1BOPMV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:12:21 -0500
In-Reply-To: <20110215093113.GC29871@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2011, at 4:31 AM, Christoph Hellwig wrote:

> On Mon, Feb 14, 2011 at 02:18:33PM -0500, andros@netapp.com wrote:
>> +static loff_t
>> +filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
>> +{
>> +	struct nfs4_filelayout_segment *flseg = FILELAYOUT_LSEG(lseg);
>> +
>> +	switch (flseg->stripe_type) {
>> +	case STRIPE_SPARSE:
>> +		return offset;
>> +
>> +	case STRIPE_DENSE:
>> +	{
>> +		u32 stripe_width;
>> +		u64 tmp, off;
>> +		u32 unit = flseg->stripe_unit;
>> +
>> +		stripe_width = unit * flseg->dsaddr->stripe_count;
>> +		tmp = off = offset - flseg->pattern_offset;
>> +		do_div(tmp, stripe_width);
>> +		return tmp * unit + do_div(off, unit);
> 
> For readability's sake I'd split this out into a helper:
> 
> static loff_t
> filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
> 			    loff_t offset)
> {
> 	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
> 	u64 tmp;
> 
> 	offset -= flseg->pattern_offset
> 
> 	tmp = off;
> 	do_div(tmp, stripe_width);
> 
> 	return tmp * unit + do_div(offset, flseg->stripe_unit);
> }

OK - I see your point.

-->Andy

> 
> ...
> 
> 
> 	case STRIPE_DENSE:
> 		return filelayout_get_dense_offset(flset, offset);
> 

