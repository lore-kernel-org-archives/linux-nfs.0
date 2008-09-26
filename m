From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Fri, 26 Sep 2008 12:23:56 -0400
Message-ID: <RTPCLUEXC2-PRDIIZS20000003d@RTPMVEXC1-PRD.hq.netapp.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
 <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
 <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com>
 <1222445161.10150.4.camel@localhost>
 <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com> <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.co
 m>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: "howard chen" <howachen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44928 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752372AbYIZQYF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 12:24:05 -0400
In-Reply-To: <b66ddc900809260913r6c009658p958d88aa2e1be99e-JsoAwUIsXouhRSP0FMvGiw@public.gmane.org
 m>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <RTPCLUEXC2-PRDM3SOl0000001f-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <b66ddc900809260805g71578cacr73a526e87a77e677-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <RTPCLUEXC2-PRDNXRPm0000003a-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
 <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <1222445161.10150.4.camel@localhost>
 <b66ddc900809260913r6c009658p958d88aa2e1be99e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have you tried my suggestion of replacing "10.10.10.2" with "*" in
your server's exports, as a test? It will tell us whether you have
an IP aliasing issue.

As for TCP, no special mount parameters are required. The timers
and algorithms are all adaptive and preconfiguring them is often
counterproductive. You still haven't shown "uname -a" for your
client, but if it's anything recent, you don't even need to specify
tcp, it's the default.

Tom.

At 12:13 PM 9/26/2008, howard chen wrote:
>Hi,
>
>Thanks all for your input first.
>
>On Sat, Sep 27, 2008 at 12:06 AM, Trond Myklebust
><trond.myklebust@fys.uio.no> wrote:
>
>> What does
>>
>>  'rpcinfo -p 10.10.10.1'
>
> program vers proto   port
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100021    1   udp  32773  nlockmgr
>    100021    3   udp  32773  nlockmgr
>    100021    4   udp  32773  nlockmgr
>    100021    1   tcp  32779  nlockmgr
>    100021    3   tcp  32779  nlockmgr
>    100021    4   tcp  32779  nlockmgr
>    100024    1   udp    883  status
>    100024    1   tcp    886  status
>    100011    1   udp    821  rquotad
>    100011    2   udp    821  rquotad
>    100011    1   tcp    824  rquotad
>    100011    2   tcp    824  rquotad
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100003    4   udp   2049  nfs
>    100003    2   tcp   2049  nfs
>    100003    3   tcp   2049  nfs
>    100003    4   tcp   2049  nfs
>    100005    1   udp    891  mountd
>    100005    1   tcp    894  mountd
>    100005    2   udp    891  mountd
>    100005    2   tcp    894  mountd
>    100005    3   udp    891  mountd
>    100005    3   tcp    894  mountd
>
>
>> give you? Also,
>>
>>  'showmount -e 10.10.10.1'
>>
>
>
>Export list for 10.10.10.1
>/data0/tmp     10.10.10.2
>
>
>
>
>> That depends. In my experience, the difference in performance on an
>> unloaded network, then UDP will outperform TCP by ~10%. However, if you
>> have a heavily loaded network with lots of dropped packets, then TCP
>> will usually give much better performance than UDP.
>
>Good to know! I will definitely have a test, any parameters are also
>recommend together with TCP so I can do a fair benchmark?
>
>
>Thank you again.

