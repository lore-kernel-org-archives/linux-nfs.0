From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 10/16] pnfs: wave 3: coelesce across layout stripes
Date: Tue, 15 Feb 2011 10:10:13 -0500
Message-ID: <D17E8A5C-9E94-44FC-B595-343FCD28C91A@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com> <1297711116-3139-11-git-send-email-andros@netapp.com> <1297726920.23841.51.camel@heimdal.trondhjem.org> <AANLkTikRMT=xxXp+7ky9kaYCOn2-y0obpJ7-gW96NkN5@mail.gmail.com> <1297782220.10103.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
	Andy Adamon <andros@citi.umich.edu>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Fred Isaman <iisaman@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Oleg Drokin <green-SOTZviwpzew/JUsKyNonYw@public.gmane.org>,
	Tao Guo <guotao-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28567 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755142Ab1BOPKP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Feb 2011 10:10:15 -0500
In-Reply-To: <1297782220.10103.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2011, at 10:03 AM, Trond Myklebust wrote:

> On Tue, 2011-02-15 at 09:43 -0500, William A. (Andy) Adamson wrote: 
>> On Mon, Feb 14, 2011 at 6:42 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Mon, 2011-02-14 at 14:18 -0500, andros@netapp.com wrote:
>>>> From: Fred Isaman <iisaman@netapp.com>
>>>> 
>>>> Add a pg_test layout driver hook which is used to avoid coelescing I/O across
>>>> layout stripes.
>>> 
>>> Doesn't this belong before [PATCH 09/16] pnfs: wave 3: shift
>>> pnfs_update_layout locations?
>> 
>> The pg_test uses the pg_lseg declared in [PATCH 09/16] pnfs: wave 3:
>> shift pnfs_update_layout locations, which is why the patches are
>> ordered this way.
> 
> What prevents you from moving the pg_lseg declaration into this patch,
> and just relying on the initialisation being NULL?
> 
> The current ordering means that applying 9/16 without 10/16 gives rise
> to broken stripe sizes.

OK - Good reason.

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

