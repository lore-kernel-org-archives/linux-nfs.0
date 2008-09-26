From: "howard chen" <howachen@gmail.com>
Subject: Re: Permission denied when mounting NFS (was okay before)
Date: Sat, 27 Sep 2008 00:13:45 +0800
Message-ID: <b66ddc900809260913r6c009658p958d88aa2e1be99e@mail.gmail.com>
References: <b66ddc900809260432o4ecfab4fk39b0d06002bae57a@mail.gmail.com>
	 <RTPCLUEXC2-PRDM3SOl0000001f@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260805g71578cacr73a526e87a77e677@mail.gmail.com>
	 <RTPCLUEXC2-PRDNXRPm0000003a@RTPMVEXC1-PRD.hq.netapp.com>
	 <b66ddc900809260857o39c4ef31h75af8e7eaf9448fc@mail.gmail.com>
	 <1222445161.10150.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:56184 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbYIZQNq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 12:13:46 -0400
Received: by gxk9 with SMTP id 9so8477439gxk.13
        for <linux-nfs@vger.kernel.org>; Fri, 26 Sep 2008 09:13:45 -0700 (PDT)
In-Reply-To: <1222445161.10150.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Thanks all for your input first.

On Sat, Sep 27, 2008 at 12:06 AM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:

> What does
>
>  'rpcinfo -p 10.10.10.1'

 program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32773  nlockmgr
    100021    3   udp  32773  nlockmgr
    100021    4   udp  32773  nlockmgr
    100021    1   tcp  32779  nlockmgr
    100021    3   tcp  32779  nlockmgr
    100021    4   tcp  32779  nlockmgr
    100024    1   udp    883  status
    100024    1   tcp    886  status
    100011    1   udp    821  rquotad
    100011    2   udp    821  rquotad
    100011    1   tcp    824  rquotad
    100011    2   tcp    824  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100005    1   udp    891  mountd
    100005    1   tcp    894  mountd
    100005    2   udp    891  mountd
    100005    2   tcp    894  mountd
    100005    3   udp    891  mountd
    100005    3   tcp    894  mountd


> give you? Also,
>
>  'showmount -e 10.10.10.1'
>


Export list for 10.10.10.1
/data0/tmp     10.10.10.2




> That depends. In my experience, the difference in performance on an
> unloaded network, then UDP will outperform TCP by ~10%. However, if you
> have a heavily loaded network with lots of dropped packets, then TCP
> will usually give much better performance than UDP.

Good to know! I will definitely have a test, any parameters are also
recommend together with TCP so I can do a fair benchmark?


Thank you again.
