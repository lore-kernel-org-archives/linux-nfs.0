Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f175.google.com ([209.85.160.175]:61501 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751154AbaHZPgS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 11:36:18 -0400
Received: by mail-yk0-f175.google.com with SMTP id q200so11415761ykb.20
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 08:36:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>
References: <53FCA183.8000605@plexistor.com>
	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>
Date: Tue, 26 Aug 2014 11:36:17 -0400
Message-ID: <CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 26, 2014 at 11:24 AM, Matt W. Benjamin <matt@linuxbox.com> wrote:
> IIUC, the problem is the forechannel slot count, since the call you want to make synchronously is on the forechannel?

Yep. layoutcommit will be sent on the fore channel, which is why it
can deadlock with the initial layoutget (or whatever operation that
triggered the layout recall).


> Matt
>
> ----- "Boaz Harrosh" <boaz@plexistor.com> wrote:
>
>> On 08/26/2014 05:55 PM, Trond Myklebust wrote:
>> > On Tue, Aug 26, 2014 at 10:37 AM, Boaz Harrosh <boaz@plexistor.com>
>> wrote:
>> >
>> > The above can deadlock if there are no session slots available to
>> send
>> > the layoutcommit, in which case the recall won't complete, and the
>> > layoutget won't get a reply (which would free up the slot).
>> >
>>
>> What? the back-channel and the fore-channel do not use the same
>> slots. these are two different slots, No?
>>
>> Matt, Adam you need to chip in here.
>>
>> If it is as you say, then yes it must be as Christoph wrote it.
>>
>> And the Ganesha server must be fixed because it has a slot system per
>> channel.
>>
>> Thanks
>> Boaz
>
> --
> Matt Benjamin
> The Linux Box
> 206 South Fifth Ave. Suite 150
> Ann Arbor, MI  48104
>
> http://linuxbox.com
>
> tel.  734-761-4689
> fax.  734-769-8938
> cel.  734-216-5309



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
