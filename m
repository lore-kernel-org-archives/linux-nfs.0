Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35896 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732349AbeHBPLC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 11:11:02 -0400
Date: Thu, 2 Aug 2018 09:19:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Nixiaoming <nixiaoming@huawei.com>
Cc: "jlayton@kernel.org" <jlayton@kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "trondmy@hammerspace.com" <trondmy@hammerspace.com>,
        "andros@netapp.com" <andros@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] fs/nfsd: Delete invalid assignment statements in
 nfsd4_decode_exchange_id
Message-ID: <20180802131951.GA30706@fieldses.org>
References: <20180723015711.27961-1-nixiaoming@huawei.com>
 <20180801151820.GA18338@fieldses.org>
 <E490CD805F7529488761C40FD9D26EF12A730A64@dggemm507-mbx.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E490CD805F7529488761C40FD9D26EF12A730A64@dggemm507-mbx.china.huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 02, 2018 at 01:00:26PM +0000, Nixiaoming wrote:
> On Wednesday, August 01, 2018 11:18 PM ,  J. Bruce Fields  wrote: 
> >On Mon, Jul 23, 2018 at 09:57:11AM +0800, nixiaoming wrote:
> >> READ_BUF(8);
> >> dummy = be32_to_cpup(p++);
> >> dummy = be32_to_cpup(p++);
> >> ...
> >> READ_BUF(4);
> >> dummy = be32_to_cpup(p++);
> >> 
> >> Assigning value to "dummy" here, but that stored value
> >> is overwritten before it can be used.
> >> At the same time READ_BUF() will re-update the pointer p.
> >> 
> >> delete invalid assignment statements
> >
> >Thanks, applying with a minor comment tweak to clarify that we're
> >intentionally not reading these:
> >
> >-		/* ssp_window and ssp_num_gss_handles */
> >+		/* ignore ssp_window and ssp_num_gss_handles: */
> > 		READ_BUF(8);
> > 		break;
> >
> >--b.
> >
> 
> Thanks for your advice
> I will update the patch as soon as possible according to your advice.

I've taken care of it, no need to update.

--b.
