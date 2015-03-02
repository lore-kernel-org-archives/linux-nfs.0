Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f182.google.com ([209.85.220.182]:49238 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbbCBAw3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 Mar 2015 19:52:29 -0500
Received: by mail-vc0-f182.google.com with SMTP id id10so9863256vcb.13
        for <linux-nfs@vger.kernel.org>; Sun, 01 Mar 2015 16:52:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425237291.24845.13.camel@primarydata.com>
References: <1425237291.24845.13.camel@primarydata.com>
Date: Sun, 1 Mar 2015 19:52:28 -0500
Message-ID: <CAHQdGtSTJoKJZ8y72oLWTv30AZxVsRWAU0pTjZJy18jQ7Dhadw@mail.gmail.com>
Subject: Re: Weird TCP hang when doing loopback NFS (wireshark traces attached)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce James Fields <bfields@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

On Sun, Mar 1, 2015 at 2:14 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Hi,
>
> When doing testing of NFSv3 loopback mounts (client and server are on
> the same IP address), I'm seeing a very reproducible hang in which the
> client stops receiving data from the server. The TCP connection is still
> marked as established, and the server appears to continue to receive and
> send data, however the client does not.
>
> So far, I've reproduced on both v4.0-rc1, and the Fedora v3.18.7 kernel.
>
> The reproducer is simply to loopback mount using NFSv3, and then run the
> 'fsx' filesystem exerciser. I'm usually able to trigger the hang with
> "fsx -N 100000 foobar".
>
> I've attached a couple of wireshark trace of a few frames just before
> and during the hang in case it jogs any memories.

This bug appears to go away when I disable the splice()-based reads by
clearing the RQ_SPLICE_OK flag.

I noticed that it always involved a combination of a READ and a
truncating SETATTR call. Are you sure that it is safe to share
pagecache pages directly with sendpage() in this way? As far as I can
tell, there is no locking to prevent them from being modified while in
the TCP send queue.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
