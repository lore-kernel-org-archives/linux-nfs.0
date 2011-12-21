Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:44107 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751418Ab1LUULt convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Dec 2011 15:11:49 -0500
Received: by obcwo16 with SMTP id wo16so3482007obc.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Dec 2011 12:11:49 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <1324475851.7709.12.camel@lade.trondhjem.org>
References: <CAGue13pWcOKeQH9nr=VK2ZCMLpC2s1=yQwuyxAEuuizjSh1Z+g@mail.gmail.com>
	<1324475851.7709.12.camel@lade.trondhjem.org>
Date: Wed, 21 Dec 2011 21:11:49 +0100
Message-ID: <CAGue13pSKnxNK_UWnh0KXz_w-CbeWQjmDS1H7ZBVMRiV25JqmQ@mail.gmail.com>
Subject: Re: Session timeout on RHEL6.2
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 21, 2011 at 2:57 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2011-12-21 at 10:24 +0100, Tigran Mkrtchyan wrote:
>> Dear friends,
>>
>> We are observing strange behavior with RHEL 6.2:
>>
>> Our the server lease time is 90 seconds. I can see that client
>> sends SEQUENCE every 60 sec. And this is for some hours ( ~8 ).
>> At some point client sends SEQUENCE after 127 seconds and
>> gets, as expected, EXPIRED.
>
> Why shouldn't the client be allowed to let the lease expire if nothing
> is using that filesystem?
>
>> I this point I have to blame myself.
>> Client comes with EXCHANGE_ID using the same clientid.
>> We did not garbage collected clientid internally as this happens after
>> 2*LEASE_TIME
>> and return EXPIRE. This ping-pong never ends.
>>
>> This is probably mostly a bug on my side. Nevertheless we never observed late
>> SEQUENCE with kernel > 2.6.39. A short packet dump attached.
>>
>> I can open bug at RHEL if required.
>
> I wouldn't consider that a bug.

As I said, there is a bug in exchange_id processing ( case 3 ) on my
side. But to me it's sounds strange that client after more than 8
hours of sending only sequence decided to send one of them later than
lease time. Especially, that we did not have it with other kernels.

Anyway, we will update our server tomorrow with bugfix.

Tigran.

>
> Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
