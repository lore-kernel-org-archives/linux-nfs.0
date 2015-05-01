Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f44.google.com ([209.85.216.44]:45986 "EHLO
	mail-vn0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbbEARrh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 13:47:37 -0400
Received: by vnbg190 with SMTP id g190so10654947vnb.12
        for <linux-nfs@vger.kernel.org>; Fri, 01 May 2015 10:47:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150501173759.GA23778@infradead.org>
References: <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
	<20150429173454.GA23284@fieldses.org>
	<20150430062558.GA25660@infradead.org>
	<2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
	<20150430143731.GA22038@infradead.org>
	<CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
	<20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
	<E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
	<20150501172345.GB29624@infradead.org>
	<CAHQdGtTAiwQ4rRpLCtS+V04n6hSg3R4Q3V_QFn+V2OR7bK+41w@mail.gmail.com>
	<20150501173759.GA23778@infradead.org>
Date: Fri, 1 May 2015 13:47:36 -0400
Message-ID: <CAHQdGtSxxd4mG6uEu2GC0eUE5RcEnvWqsvzgL4AhFYUNSu0L=g@mail.gmail.com>
Subject: Re: [PATCH, RFC] backchannel overflows
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 1, 2015 at 1:37 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, May 01, 2015 at 01:28:12PM -0400, Trond Myklebust wrote:
>> The concern is not so much static vs dynamic. The concern is limiting
>> incoming RPC calls to the number allowed by the NFSv4.1 session. Right
>> now, the static allocation enforces the limit of 1 slot that the
>> client offers to the server (albeit with the race) and so I want any
>> replacement to meet the same requirement.
>
> Either variant will allow accepting more than one backchannel
> request at the RPC layer, that's the whole point.  With the simple
> patch I posted it will accept a 2nd one, with dynamic allocation
> the number would be potentially unbound.

If you do it wrong, yes. The point is if you do the allocation as part
of the send process, then you prevent unbounded growth.

> But given that the NFS client already enforces the slot limit
> properly in validate_seqid, and even returns the proper nfs error
> for this case I don't really see what enforcing it at a lower level
> we we can't even report proper errors buys us.

It buys us better congestion control. We don't even need to process the request.

Cheers
  Trond
