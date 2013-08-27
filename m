Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:65376 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab3H0WBk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Aug 2013 18:01:40 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Mark Young <MYoung@nvidia.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Matt Craighead <mcraighead@nvidia.com>
Subject: RE: Issue found with kernel/net/sunrpc/xdr.c
Date: Tue, 27 Aug 2013 22:01:38 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA94677C96F@SACEXCMBX04-PRD.hq.netapp.com>
References: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
In-Reply-To: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of Mark Young
> Sent: Tuesday, August 27, 2013 5:17 PM
> To: linux-nfs@vger.kernel.org
> Cc: Matt Craighead
> Subject: Issue found with kernel/net/sunrpc/xdr.c
> 
> I was pointed to this mailing list by Brian Fields.
> 
>  We're currently seeing NFS data corruption, which we traced back to
> memory corruption that happens in the function _shift_data_right_pages in
> net/sunrpc/xdr.c.
> 
>  When we see the issue, we're running a 32bit os with systems running with
> more than 1GB of physical memory.   The errant behavior appears to be that
> two calls to kmap_atomic (on 32bit systems with highmem present) with the
> same physical address (on addresses within highmem)  will return two
> different vaddrs.    In our assessment, this confuses the memmove code into
> thinking that the two addresses are non-overlapping in spite of the fact that
> they are overlapping in physical space.  This, in turn, results in corruption.
> 
>  A proposed solution to the problem would involve calling kmap_atomic only
> once in the case that the pgfrom and pgto are identical, and then re-using
> the resultant vaddr for both vto and vfrom.
> 
> Any insight on the issue or the proposed solution would be greatly
> appreciated.

I'm fine with that solution. Mind sending a duly conformant patch w/ a signed-off-by line?

Thanks
  Trond
