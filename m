Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:59060 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567Ab2DHSR2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Apr 2012 14:17:28 -0400
Received: by vcqp1 with SMTP id p1so1430890vcq.19
        for <linux-nfs@vger.kernel.org>; Sun, 08 Apr 2012 11:17:28 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <CAGue13ogPBNm9ETRWou94ULmRTZdpMYTsW8xNe2jJKb-Ve4Gow@mail.gmail.com>
References: <CAGue13oi+486dGpgsUpn0EkiNmf8pLM60XzjT7q+r3gkzYAL0g@mail.gmail.com>
	<1333908466.18901.1.camel@lade.trondhjem.org>
	<CAGue13ogPBNm9ETRWou94ULmRTZdpMYTsW8xNe2jJKb-Ve4Gow@mail.gmail.com>
Date: Sun, 8 Apr 2012 20:17:27 +0200
Message-ID: <CAGue13rBMoQZOUwKS4h_Ea7U+2u83YMCRY3AutXJcq4QuAw08w@mail.gmail.com>
Subject: Re: corrupted rpc message on GSS_DESTROY
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 8, 2012 at 8:07 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2012-04-06 at 23:56 +0200, Tigran Mkrtchyan wrote:
>> Hi,
>>
>> We are still see issued described in:
>>
>> http://www.spinics.net/lists/linux-nfs/msg22142.html
>>
>> Now even the see partial context.
>> By looking at kernel's GSS implementation I see following:
>>
>> The auth_gss.c:gss_marshal() in some cases may return NULL.
>> The NULL value is passed to xdr_adjust_iovec() which
>> calculates message length as:
>>
>>  return iov->iov_len = ((u8 *) p - (u8 *) iov->iov_base);
>>
>> where p is NULL in such case.  I don't think it's an expected
>> behavior.
>
> As far as I can see, a zero reply in gss_marshal() results in
> rpc_xdr_encode() printing "RPC: couldn't encode RPC header, exit EIO"
> and then calling rpc_exit(). I don't see how that could result in a
> corrupted buffer.

may be they are unrelated. I will keep looking.

Tigran.
>
> Cheers
>  Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
