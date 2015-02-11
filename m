Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:47429 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753057AbbBKPPp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 10:15:45 -0500
Received: by mail-vc0-f174.google.com with SMTP id id10so1362710vcb.5
        for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2015 07:15:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211145413.GC25696@fieldses.org>
References: <20150202161557.GF22301@fieldses.org>
	<20150211123757.GA10532@infradead.org>
	<20150211141257.GA25696@fieldses.org>
	<20150211141619.GA24299@infradead.org>
	<20150211145413.GC25696@fieldses.org>
Date: Wed, 11 Feb 2015 10:15:43 -0500
Message-ID: <CAHQdGtSfeu_+mKfgX55kty-UJ+bT2ZZ0hi6OBYGmGrsYVk+hkg@mail.gmail.com>
Subject: Re: [PATCH] nfsd: default NFSv4.2 to on
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 11, 2015 at 9:54 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Feb 11, 2015 at 06:16:19AM -0800, Christoph Hellwig wrote:
>> On Wed, Feb 11, 2015 at 09:12:57AM -0500, J. Bruce Fields wrote:
>> > I think so.  That's all optional--e.g. for READ_PLUS clients can
>> > determine server support using ERR_OP_NOTSUPP (or whatever it's called),
>> > and for attributes they can query the supported_attributes attribute.
>> > It's possible we'll never support everything in 4.2.
>>
>> The questions is if we need a useful subset of 4.2 to bother.
>
> Internally the virtualization people have been interested in ALLOCATE,
> SEEK, and security labels, so I'm assuming we've passed that sort of
> minimum "is there any benefit at all to turning this on" threshhold.

ACK. There is client support for that functionality that hooks into
well established system calls, which means that applications can use
it now without much in the way of changes (if at all).

>> I doubt we'll ever bother with ADBs for example, and the copy offload
>> might take a while to get everyting sorted.  But exposting most
>> attributes and supporting READ_PLUS sounds like important enought to
>> implement before considering 4.2 ready.
>
> I agree there's a documentation and marketing problem: it would simplify
> communication with users if "this server supports 4.2" reliably meant
> support for some minimum list of features.  Is that what you're thinking
> about?

None of our NFSv4 versions are 100% feature complete. Our approach on
both the client and server has been to take the functionality that is
useful to us and implement that first.
For instance, NFSv4.1 is still missing RPCSEC_GSS on the callback
channel. I do want to implement that feature some day, but that
doesn't stop me from considering NFSv4.1 to be useful in the state it
is today.

> Individual distros and other server vendors may make their own decisions
> here, so I don't know if we do much about that on our own.
>
> We could also add a little more data e.g. to /proc/self/mountstats to
> help figure out stuff like "why does copying a big file go so much
> faster on server X than server Y?".

We already have that information. As we add new RPC calls on the
client, we add corresponding entries in /proc/self/mountstats. When
copy offload goes in, it will have its own entry there, and you will
see the usage counts being bumped whenever an application calls it.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
