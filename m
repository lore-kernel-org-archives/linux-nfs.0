Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f181.google.com ([209.85.128.181]:34131 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933296Ab3CSU2y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2013 16:28:54 -0400
Received: by mail-ve0-f181.google.com with SMTP id d10so787791vea.26
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2013 13:28:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5148BE0B.9080802@tonian.com>
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com>
	<1363622128.4351.15.camel@leira.trondhjem.org>
	<51473F46.10401@tonian.com>
	<CADnza476e0FpXJJfE8OmXLRQUR3Zm_aZkX7JZRB=vGyZ-U2yDg@mail.gmail.com>
	<5148BE0B.9080802@tonian.com>
Date: Tue, 19 Mar 2013 16:28:53 -0400
Message-ID: <CADnza46Npnn=GquO8s7TPPSGZq9Cs11JJdj6t8ejDh5gYeeTYg@mail.gmail.com>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
From: Fred Isaman <faisaman4@gmail.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@kernel.org" <stable@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 19, 2013 at 3:35 PM, Benny Halevy <bhalevy@tonian.com> wrote:
> On 2013-03-18 19:04, Fred Isaman wrote:
>> A problem case is if the layout ends within the page request, which
>> can happen due to the misalignment.
>
> First, the file layout currently supports only whole file layouts so I don't see
> how that's a problem.
> Regardless, I'd rather trim the layout segment to PAGE_SIZE boundaries
> and get a new layout from the page aligned offset and on with minlength = PAGE_SIZE
> (as we do today).
>
> Benny
>

Yes, but consider....

let P = PAGE_SIZE

assume you have a layout from 0 to 4P, and you try to do a WRITE from
2P to 6P.  Now if the buffer is not page aligned, one of the nfs_page
requests will contain the file's logical 4P offset at a random
location within the nfs_page.  What happens then?

Fred
