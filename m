From: Yudong Gao <stgyd@umich.edu>
Subject: Re: Implementation of delegation
Date: Mon, 12 Jul 2010 15:00:31 -0700
Message-ID: <AANLkTimjFbkLIs4GIdR_S06bu7PPOV-JUj5uGAMs7IjG@mail.gmail.com>
References: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ@mail.gmail.com>
	<1278971292.14605.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34794 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753043Ab0GLWAw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 18:00:52 -0400
Received: by vws5 with SMTP id 5so4908786vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 15:00:51 -0700 (PDT)
In-Reply-To: <1278971292.14605.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thanks for the prompt reply!

I find that in _nfs_do_open(), _nfs4_proc_open(), which do the RPC
call to the remote server, is always called before
nfs4_opendata_to_nfs4_state(), which will further invoke
nfs4_try_open_cached().

Does this means that whenever is file is opened, the client always
need to talk to the server first?

Thanks!

best,

Yudong

On Mon, Jul 12, 2010 at 2:48 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Mon, 2010-07-12 at 14:37 -0700, Yudong Gao wrote:
>> Hi,
>>
>> I am reading the NFS source code of the file open function in kernel
>> 2.6.34, but I cannot find any implementation with delegation to allow
>> client to open a file locally without contacting the server. We are
>> tying to use delegation to do something interesting. So I am wondering
>> how much delegation support specified in the NFS 4.1 protocol is
>> available in the current Linux implementation?
>
> What's wrong with nfs4_try_open_cached()? It even works with NFSv4.0...
>
> Trond
>
>
