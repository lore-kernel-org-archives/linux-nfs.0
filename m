Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:45268 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbaHZRGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 13:06:38 -0400
Received: by mail-wg0-f45.google.com with SMTP id x12so15061444wgg.16
        for <linux-nfs@vger.kernel.org>; Tue, 26 Aug 2014 10:06:37 -0700 (PDT)
Message-ID: <53FCBE9C.40906@plexistor.com>
Date: Tue, 26 Aug 2014 20:06:36 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>, Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adam C. Emerson" <aemerson@linuxbox.com>
Subject: Re: [PATCH] pnfs: Kick a pnfs_layoutcommit_inode on recall
References: <53FCA183.8000605@plexistor.com>	<1435166875.78.1409066662291.JavaMail.root@thunderbeast.private.linuxbox.com>	<CAHQdGtT-B7NTP8T7ETgTJD1+84k_KW_5aOfrYjLpA04hoR3YsA@mail.gmail.com>	<53FCBC5A.4060304@plexistor.com> <CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>
In-Reply-To: <CAHQdGtSghgbrPr=X8O2YLq=vXbKY1y5OuOMisf6vRoj8WeF0YA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/26/2014 07:59 PM, Trond Myklebust wrote:
> On Tue, Aug 26, 2014 at 12:56 PM, Boaz Harrosh <boaz@plexistor.com> wrote:
>> On 08/26/2014 06:36 PM, Trond Myklebust wrote:
>>> On Tue, Aug 26, 2014 at 11:24 AM, Matt W. Benjamin <matt@linuxbox.com> wrote:
>>>> IIUC, the problem is the forechannel slot count, since the call you want to make synchronously is on the forechannel?
>>
>>
>> Matt no top post on a Linux mailing list ;-)
>>
>>> Yep. layoutcommit will be sent on the fore channel, which is why it
>>> can deadlock with the initial layoutget (or whatever operation that
>>> triggered the layout recall).
>>
>> Trond you said below:
>>> The above can deadlock if there are no session slots available to send
>>> the layoutcommit, in which case the recall won't complete, and the
>>> layoutget won't get a reply (which would free up the slot).
>>
>> Why would the layoutget not-get-a-reply ?
>> This is how it goes with Both ganesha server and knfsd last I tested.
>>
>> [1]
>> The LAYOUT_GET cause LAYOUT_RECALL case: (including the lo_commit)
>>
>> client          Server                                     comments
>> ~~~~~~          ~~~~~~                                     ~~~~~~~~
>> LAYOUT_GET ==>
>>            <==   LAYOUT_GET_REPLAY(ERR_RECALL_CONFLICT)
>>                                                 <--------- fore-channel is free
>>            <==   RECALL
>> LAYOUT_COMMIT ==>
>>             <==  LAYOUT_COMMIT_REPLAY
>>                                                 <--------- fore-channel is free
> 
> Beep! No free slots, so this hangs.
> 

Beep! does not do a very good of a job to explain. Sorry

What do you mean? which slot? which channel? Just above your text it says
"fore-channel is free" so are you saying it is not free? why not.
Please use more then one line of text to explain. It might be clear to
you but not to me.

>> RECALL_REPLY(NO_MATCHING) =>
>>                                                 <--------- back-channel is free

Thanks
Boaz

