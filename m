Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f48.google.com ([209.85.216.48]:45453 "EHLO
	mail-vn0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802AbbEAR2N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 13:28:13 -0400
Received: by vnbg190 with SMTP id g190so10619769vnb.12
        for <linux-nfs@vger.kernel.org>; Fri, 01 May 2015 10:28:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150501172345.GB29624@infradead.org>
References: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
	<20150429151404.GA12936@infradead.org>
	<CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
	<20150429173454.GA23284@fieldses.org>
	<20150430062558.GA25660@infradead.org>
	<2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
	<20150430143731.GA22038@infradead.org>
	<CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
	<20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com>
	<E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com>
	<20150501172345.GB29624@infradead.org>
Date: Fri, 1 May 2015 13:28:12 -0400
Message-ID: <CAHQdGtTAiwQ4rRpLCtS+V04n6hSg3R4Q3V_QFn+V2OR7bK+41w@mail.gmail.com>
Subject: Re: [PATCH, RFC] backchannel overflows
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 1, 2015 at 1:23 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Apr 30, 2015 at 01:41:02PM -0400, Chuck Lever wrote:
>> We discussed this briefly during the Linux NFS town hall meeting.
>> I agree using dynamic slot allocation for TCP is fine, and RPC/RDMA
>> can use simple overprovisioning.
>>
>> This way the upper layer (NFSv4.1 client) doesn?t have to be aware of
>> limitations in the RPC layer mechanism.
>>
>> Trond may have an additional concern that I didn?t capture.
>
> The other option would be to simply overallocate in the transport layer,
> as that is the layer which causes the problem to start with.
>
> That being said, what is the argument for doing any sort of static
> allocation here?  I'm fine with doing fully dynamic allocation if that
> works out fine, but a mixed static / dynamic allocation sounds like a
> nightmare.

The concern is not so much static vs dynamic. The concern is limiting
incoming RPC calls to the number allowed by the NFSv4.1 session. Right
now, the static allocation enforces the limit of 1 slot that the
client offers to the server (albeit with the race) and so I want any
replacement to meet the same requirement.

Cheers
  Trond
