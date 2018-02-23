Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:46888 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754583AbeBWT2F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Feb 2018 14:28:05 -0500
Received: by mail-vk0-f54.google.com with SMTP id x125so6104893vkc.13
        for <linux-nfs@vger.kernel.org>; Fri, 23 Feb 2018 11:28:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1519412975.8738.3.camel@primarydata.com>
References: <20180222192806.67911-1-kolga@netapp.com> <034fb5f1-eba5-030b-aad2-6ac5e87f2066@RedHat.com>
 <CAN-5tyE2wqrgkQuHSFy7=EDricmx6jPKA9=PnqSdf8rr_0rxwQ@mail.gmail.com>
 <6e314995-964f-e70d-cc45-fc1716b4ec81@RedHat.com> <1519412975.8738.3.camel@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Feb 2018 14:28:03 -0500
Message-ID: <CAN-5tyHzWrC7FVzCj+bSdvQFdN=5+1f750u1wWMs=2jub6y5-w@mail.gmail.com>
Subject: Re: [PATCH 1/1] NFS guard against incorrect vers inputs from nfs-utils
To: Trond Myklebust <trondmy@primarydata.com>
Cc: SteveD redhat <steved@redhat.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 23, 2018 at 2:09 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
> On Fri, 2018-02-23 at 13:45 -0500, Steve Dickson wrote:
>>
>> On 02/23/2018 12:05 PM, Olga Kornievskaia wrote:
>> > On Fri, Feb 23, 2018 at 11:24 AM, Steve Dickson <SteveD@redhat.com>
>> > wrote:
>> > > Hey Olga,
>> > >
>> > > On 02/22/2018 02:28 PM, Olga Kornievskaia wrote:
>> > > > It is possible that userland can pass to the kernel mismatching
>> > > > inputs for the minorversion. like vers=4.1,minorversion=0.
>> > > > Instead
>> > > > of making the kernel responposible for 'choosing' the
>> > > > minorversion,
>> > > > make the userland always responsible for not sending a
>> > > > mismatch.
>> > >
>> > > I'm thinking this is probably more of mount problem...
>> >
>> > Yes the problem is a broken user land sending incorrect arguments
>> > but
>> > I still think the kernel needs to do sanity checking on arguments
>> > to
>> > prevent this from happening again.
>> >
>> > > mount -t nfs4 -o minorversion=0 server:/export /mnt
>> > >
>> > > shouldn't this be a  v4.0 mount instead of a 4.2 mount?
>> >
>> > Yes I would think this should create a v4.0 mount.
>>
>> Way back when... there was some talk about deprecating
>> minorversion= flag... Since it is broken, maybe this is
>> a good time to do it?
>>
>> Thoughts?
>
> I've never liked the separate v4-only 'minorversion' keyword, which is
> why I introduced the 'version=4.x' format. My preference is therefore
> that we continue to deprecate use of 'minorversion' with a view to
> killing it off completely.

It all seems like a good idea except I wonder how widely used and
relied on "minorversion" option is. Steve you might have a good idea
about it.

>
> --
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
