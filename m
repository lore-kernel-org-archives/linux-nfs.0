Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:53355 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbbCBEbc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 23:31:32 -0500
Received: by mail-vc0-f178.google.com with SMTP id hq11so10048983vcb.9
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2015 20:31:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQcrF4fs0Tb3jTQ6iGXzOhhjRNAezrq_eOfzo_cFxh1Xw@mail.gmail.com>
References: <1425237291.24845.13.camel@primarydata.com>
	<CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
	<20150302010636.GA8033@fieldses.org>
	<CAHQdGtQcrF4fs0Tb3jTQ6iGXzOhhjRNAezrq_eOfzo_cFxh1Xw@mail.gmail.com>
Date: Sun, 1 Mar 2015 23:31:31 -0500
Message-ID: <CAHQdGtQnbPWYhdvwTGJKUD4mt8x_rmQjCH3AO4X17Y4RBSpUQQ@mail.gmail.com>
Subject: Re: Weird TCP hang when doing loopback NFS (wireshark traces attached)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce James Fields <bfields@fieldses.org>
Cc: Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 1, 2015 at 8:20 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Sun, Mar 1, 2015 at 8:06 PM, Bruce James Fields <bfields@fieldses.org> wrote:
>> On Sun, Mar 01, 2015 at 07:52:28PM -0500, Trond Myklebust wrote:
>>> Hi Bruce,
>>>
>>> On Sun, Mar 1, 2015 at 2:14 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>> > Hi,
>>> >
>>> > When doing testing of NFSv3 loopback mounts (client and server are on
>>> > the same IP address), I'm seeing a very reproducible hang in which the
>>> > client stops receiving data from the server. The TCP connection is still
>>> > marked as established, and the server appears to continue to receive and
>>> > send data, however the client does not.
>>> >
>>> > So far, I've reproduced on both v4.0-rc1, and the Fedora v3.18.7 kernel.
>>> >
>>> > The reproducer is simply to loopback mount using NFSv3, and then run the
>>> > 'fsx' filesystem exerciser. I'm usually able to trigger the hang with
>>> > "fsx -N 100000 foobar".
>>> >
>>> > I've attached a couple of wireshark trace of a few frames just before
>>> > and during the hang in case it jogs any memories.
>>>
>>> This bug appears to go away when I disable the splice()-based reads by
>>> clearing the RQ_SPLICE_OK flag.
>>>
>>> I noticed that it always involved a combination of a READ and a
>>> truncating SETATTR call. Are you sure that it is safe to share
>>> pagecache pages directly with sendpage() in this way? As far as I can
>>> tell, there is no locking to prevent them from being modified while in
>>> the TCP send queue.
>>
>> This is the stable-pages problem that we've had forever, isn't it?  Or
>> is this a different problem?
>
> It is causing the TCP socket to hang, so it goes beyond the usual
> stable pages issue.
>

Confirming that clearing RQ_SPLICE_OK fixes the issue on all kernel
that I've tested so far.
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
