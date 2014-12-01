Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:62507 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932094AbaLAUI6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 15:08:58 -0500
Received: by mail-vc0-f172.google.com with SMTP id hq11so5139877vcb.3
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2014 12:08:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141201195636.GC30001@fieldses.org>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
	<20141119213758.GE14207@fieldses.org>
	<20141119165957.04e6e9c2@tlielax.poochiereds.net>
	<546DF808.1000905@Netapp.com>
	<20141201195636.GC30001@fieldses.org>
Date: Mon, 1 Dec 2014 15:08:57 -0500
Message-ID: <CAHQdGtRaZ33kzweTMiSQhjAmUkQdHrq140obhrvmY2bZC=xcdg@mail.gmail.com>
Subject: Re: [PATCH 00/10] sunrpc: fixes and cleanups for svc creation and
 thread handling
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 1, 2014 at 2:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Nov 20, 2014 at 09:17:44AM -0500, Anna Schumaker wrote:
>> On 11/19/2014 04:59 PM, Jeff Layton wrote:
>> > On Wed, 19 Nov 2014 16:37:58 -0500
>> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> >
>> >> On Wed, Nov 19, 2014 at 07:51:12AM -0500, Jeff Layton wrote:
>> >>> Patch #1 in this series is a bugfix, but probably isn't worth sending to
>> >>> stable. The rest are just cleanups in preparation for some other patches
>> >>> that I have queued up. Can you consider these for 3.19?
>> >> Sure, I've read through them, they look fine.
>> >>
>> >> When I tried to apply them to my for-3.19 there were rejects due to
>> >> tracing stuff in include/trace/events/sunrpc.h.  I haven't tried to
>> >> investigate yet.
>> >>
>> >> --b.
>> >>
>> > Ahh yeah. These are based on top of the tracepoint patches I sent to
>> > Trond a couple of weeks ago. I think he's planning to merge those in
>> > 3.19 too, but I don't think he's done that yet. Anna may have though...
>>
>> I have them in a private tree on my laptop that I use for testing.  Want me to push them out somewhere?
>
> That'd help me at least test, but we need something more than a
> temporary testing branch to get ready for the merge window.  Choices
> include:
>
>         - Trond merges them all now, I pull that and apply these on top.
>         - I merge them instead, or we divide the patches between us
>           somehow.  Worst case, it's probably even OK if there's a patch
>           or two that we both apply.
>
> In any case we need to get that sorted out now-ish as the merge window's
> probably starting next week.
>

All patches that I plan on merging for the next window were pushed out
last Friday. Jeff's tracepoint and debugfs patchset should therefore
be present in my nfs-for-next and linux-next branches on
git.linux-nfs.org.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
