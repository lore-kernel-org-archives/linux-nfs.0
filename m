Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f41.google.com ([209.85.216.41]:33499 "EHLO
	mail-vn0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbbD3PCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 11:02:31 -0400
Received: by vnbf1 with SMTP id f1so7539815vnb.0
        for <linux-nfs@vger.kernel.org>; Thu, 30 Apr 2015 08:02:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
References: <20150428202157.GA23972@infradead.org>
	<1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
	<20150429151404.GA12936@infradead.org>
	<CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
	<20150429173454.GA23284@fieldses.org>
	<20150430062558.GA25660@infradead.org>
	<2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
	<20150430143731.GA22038@infradead.org>
	<CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com>
Date: Thu, 30 Apr 2015 11:02:30 -0400
Message-ID: <CAHQdGtTOsSU1S55+04Yb=_VHgros1kzkgXOHtmJepteD7Y+FnA@mail.gmail.com>
Subject: Re: [PATCH, RFC] backchannel overflows
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies for the resend...

On Thu, Apr 30, 2015 at 11:01 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
>
>
> On Thu, Apr 30, 2015 at 10:37 AM, Christoph Hellwig <hch@infradead.org>
> wrote:
>>
>> On Thu, Apr 30, 2015 at 10:34:02AM -0400, Chuck Lever wrote:
>> > I?ve been discussing the possibility of adding more session slots on
>> > the Linux NFS client with jlayton. We think it would be straightforward,
>> > once the workqueue-based NFSD patches are in, to make the backchannel
>> > service into a workqueue. Then it would be a simple matter to increase
>> > the number of session slots.
>> >
>> > We haven?t discussed what would be needed on the server side of this
>> > equation, but sounds like it has some deeper problems if it is not
>> > obeying the session slot table limits advertised by the client.
>>
>> No, the client isn't obeying it's own slot limits
>>
>> The problem is when the client responds to a callback it still
>> holds a references on rpc_rqst for a while.  If the server
>> sends the next callback fast enough to hit that race window the
>> client incorrectly rejects it.  Note that we never even get
>> to the nfs code that check the slot id in this case, it's low-level
>> sunrpc code that is the problem.
>
>
> We can add dynamic allocation of a new slot as part of the backchannel reply
> transmit workload. That way we close the race without opening for violation
> of session limits.
>
> Cheers
>   Trond
