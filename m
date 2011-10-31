Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:40670 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637Ab1JaRCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 13:02:53 -0400
Received: by vws1 with SMTP id 1so5033954vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2011 10:02:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1320079501.4714.9.camel@lade.trondhjem.org>
References: <1320074136-3087-1-git-send-email-bergwolf@gmail.com>
 <1320074136-3087-2-git-send-email-bergwolf@gmail.com> <1320076148.4714.4.camel@lade.trondhjem.org>
 <CA+a=Yy4L4GDsQL6hHG4DRLNPmvkMBpk4mW9ofWbQob+z2a1G2A@mail.gmail.com> <1320079501.4714.9.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 1 Nov 2011 01:02:32 +0800
Message-ID: <CA+a=Yy4O1SvrmvWQtgS6AydejqaTreo4rZHkdDQJjLrFQjee1A@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs41: handle BLK_LAYOUT CB_RECALL_ANY
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 1, 2011 at 12:45 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2011-11-01 at 00:38 +0800, Peng Tao wrote:
>> On Mon, Oct 31, 2011 at 11:49 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Mon, 2011-10-31 at 08:15 -0700, Peng Tao wrote:
>> >> For blocklayout, we need to issue layoutreturn to return layouts when
>> >> handling CB_RECALL_ANY.
>> >
>> > Why?
>> Because replying NFS4_OK to CB_RECALL_ANY indicates that client knows
>> that server wants client to return layout. And server will be waiting
>> for layoutreturn in such case.
>
> No it doesn't. NFS4_OK means that the client acknowledges that it has
> been given a new limit on the number of recallable objects it can keep.
> There is no requirement in the text that it should send layoutreturn or
> that the server should expect that.
Per RFC5661 section 20.6.3:
It is the job of the client to bring down the size of the
   recallable object set in line with each CB_RECALL_ANY received

For layout objects, the only way client can bring down the object
number is to send layoutreturn.

Besides, the moment client gets CB_RECALL_ANY is likely because server
reaches some resource threshold. If client doesn't send layoutreturn,
server can refusing client from getting more layouts.

>
> In any case, there is no reason to make a difference between block,
> object and file layouts when it comes to CB_RECALL_ANY. The code to
> handle it should be the same for all.
>
object layout isn't handling CB_RECALL_ANY yet. And from current code,
I was assuming file layouts have their own method at server side to
handle it (e.g., translating NFS4_OK of CB_RECALL_ANY into client has
dropped all its layout...).So I made it for block only.

Thanks,
Tao

> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>



-- 
Thanks,
-Bergwolf
