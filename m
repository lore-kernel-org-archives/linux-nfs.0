Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f170.google.com ([209.85.220.170]:58979 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbaHEVYP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2014 17:24:15 -0400
Received: by mail-vc0-f170.google.com with SMTP id lf12so2682944vcb.1
        for <linux-nfs@vger.kernel.org>; Tue, 05 Aug 2014 14:24:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140805204202.GZ23341@fieldses.org>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
	<20140804133641.GA23341@fieldses.org>
	<20140805204202.GZ23341@fieldses.org>
Date: Tue, 5 Aug 2014 17:24:14 -0400
Message-ID: <CAHQdGtSXumFk8adP3=h1-dkqr7dQ36g+TMRct4uHC21wk54rOQ@mail.gmail.com>
Subject: Re: [PATCH 00/11] SUNRPC server scalability improvements
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 5, 2014 at 4:42 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Aug 04, 2014 at 09:36:41AM -0400, Bruce Fields wrote:
>> On Sun, Aug 03, 2014 at 01:03:02PM -0400, Trond Myklebust wrote:
>> > When testing knfsd on 10GigE and 40GigE networks, we've been hitting a few
>> > scalability issues that are seriously affecting performance. The main issue
>> > was scalability of the pool->sp_lock, but we also hit a couple of things
>> > like the use of ioctls in the receive fast path, as well as some issues
>> > with heuristic tests being performed twice in the same path.
>> >
>> > This is not urgent, and can definitely be delayed until the 3.18 merge
>> > window, however since the performance gains were significant over NFSv3,
>> > I thought I'd share now.
>>
>> Thanks!  On a quick skim these and the DRC patches look good.
>>
>> My first priority is to see if I can merge the last of the state locking
>> patches which are already in nfsd-next, so yes I'll probably queue these
>> up for 3.18 later.
>
> Though note I already applied the first three--I'm assuming the versions
> of those posted here are the same as the ones previously applied.  (See
> git://linux-nfs.org/~bfields/linux.git for-3.17.)
>

Yes. Those first 3 should be identical to the patches that I posted earlier.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
