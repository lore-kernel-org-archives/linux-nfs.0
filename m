Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:35296 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbeD0XLO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2018 19:11:14 -0400
Received: by mail-ua0-f171.google.com with SMTP id a2so1736877uak.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Apr 2018 16:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180427160349.GA22412@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com> <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org> <20180417065203.GA15145@infradead.org>
 <CAN-5tyEjCEo+P=p2nPkEiwa3BwM8Nj_N3KmvMXMU+VDmQJcjLA@mail.gmail.com>
 <1b45673f-516d-51ff-a1ef-8b07b9dd8619@RedHat.com> <1E0C45FE-2214-41FB-8634-1005CC13AD9E@netapp.com>
 <20180418070842.GC8764@infradead.org> <CAN-5tyGVc5myRVrnS0vc3gKq5NbhhrkVVDuLZPn2XxXoO-=T8A@mail.gmail.com>
 <20180427160349.GA22412@parsley.fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 27 Apr 2018 19:11:12 -0400
Message-ID: <CAN-5tyH3VAcOXZ87ZGJFn5BffO+Si9A1shEgUsP=H-FUu+K23A@mail.gmail.com>
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        Steve Dickson <SteveD@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 27, 2018 at 12:03 PM, J. Bruce Fields <bfields@redhat.com> wrot=
e:
> On Tue, Apr 24, 2018 at 04:29:14PM -0400, Olga Kornievskaia wrote:
>> On Wed, Apr 18, 2018 at 3:08 AM, Christoph Hellwig <hch@infradead.org> w=
rote:
>> > On Tue, Apr 17, 2018 at 11:19:25AM -0400, Olga Kornievskaia wrote:
>> >> Yes I agree. Let=E2=80=99s please decide if this will go in (with wha=
tever code improvements are required) or let=E2=80=99s drop it.
>> >
>> > Well, my vote is very clearly to drop it.
>>
>> Bruce, when will you make a decision about this? Is there something
>> more that needs to happen before it can be decided if the "async"
>> patches are moving forward (and then "inter" patches).
>
> I'm OK with the patches.
>
> It could help to have some more information about actual customer use
> cases: who specifically is asking for this, and what about their
> situation makes them believe they'll benefit?

I'm really not involved with customer or know of how exactly they will
benefit. I have some knowledge of some company that is interested in
using copy offload functionality in game development. I have no
details. It has been talked about a case scenario of copying VM
images. I don't know if VMware uses copy offload or not.

> But to me it seems obvious that server-to-server copy will be faster in
> some cases as long there's not some screwup preventing it from using the
> server-to-server bandwidth (and your numbers don't show any).  So I'm
> not terribly worried about this.
>
> If we wanted to simplify I think we could ditch the asynchronous
> protocol and still make server-to-server copy work as a series of
> synchronous calls.  (Or maybe that would make getting good performance
> the complicated part.)

I'm not in favor of dropping asynchronous piece as I think it's an
important performance improvement. It's likely it won't be must of an
improvement due to an overhead of establishing clientid/session for
every "chuck" of the copy that will be sent synchronously.

> The only security issue I'm worried about is the fact that you can make
> it try to copy from any arbitrary IP address.  I'd be satisfied if we
> document the issue and make server-to-server-copy support require a
> runtime switch that defaults to off.  (And with that in place I don't
> see a need to also provide a build option.)

Ok, runtime option, I'll work on it.
