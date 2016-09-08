Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:58272 "EHLO fiona.linuxhacker.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932500AbcIHO4A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Sep 2016 10:56:00 -0400
Subject: Re: NFS client stuck in a tight loop
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=windows-1252
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <59CD8653-D109-408E-A5BA-124220051094@primarydata.com>
Date: Thu, 8 Sep 2016 10:55:50 -0400
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Message-Id: <730673D2-B564-4B0A-B69F-170192BB5302@linuxhacker.ru>
References: <0ABF496B-2E1F-46B6-A3EA-55C447F71073@linuxhacker.ru> <59CD8653-D109-408E-A5BA-124220051094@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 7, 2016, at 10:35 AM, Trond Myklebust wrote:
>> You can do umount -f and then unmount does work on the second try,
>> this also results in the following dmesg message:
>> [155381.995368] NFS: nfs4_reclaim_open_state: unhandled error -5
>> 
>> I don't know this code well enough to take my own stab at a fix, but I can
>> help testing if needed.
> 
> I did send out a set of patches a week ago that addresses an issue in this area, and I know of a couple more holes that need to be plugged.

I tried the tip of your testing branch (hash 05c974669ecec510a85d8534099bb75404e82c41)
and the problem is still there, though possibly a bit harder to trigger.

Bye,
    Oleg