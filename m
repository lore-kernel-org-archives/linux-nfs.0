Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:39115 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbeESJHf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 19 May 2018 05:07:35 -0400
Received: by mail-wm0-f54.google.com with SMTP id f8-v6so19042230wmc.4
        for <linux-nfs@vger.kernel.org>; Sat, 19 May 2018 02:07:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <494F9084-A5C6-42E4-B198-29747B5929FF@oracle.com>
References: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
 <494F9084-A5C6-42E4-B198-29747B5929FF@oracle.com>
From: Naruto Nguyen <narutonguyen2018@gmail.com>
Date: Sat, 19 May 2018 16:07:33 +0700
Message-ID: <CANpxKHHg2yrtWqZiM+Hnz+GgpaPyCW8ZmJ6OsGKdpBt9qgM+fA@mail.gmail.com>
Subject: Re: Conflict tcp port between rpcinfo and other applications
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Thanks for your reply.

Yep, could you please post your patch here? You mean that after I
applied your patch and running rpcinfo as a regular user, the CLNT API
will pick a dynamic port instead of reserved port, right? or without
your patch, if I run as a normal user instead of root, rpcinfo will
pick dynamic port instead of reserve port?


"Is it possible to give the rpcinfo executable a set of file
capabilities that disables CAP_NET_BIND_SERVICE?"

Could you please explain more how to disable CAP_NET_BIND_SERVICE?
that's look good as well.

Thanks,
Brs,
Bao

On 18 May 2018 at 21:43, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On May 18, 2018, at 7:09 AM, Naruto Nguyen <narutonguyen2018@gmail.com> wrote:
>>
>> Hello everyone,
>>
>> When I use "rpcinfo -T tcp $Host_A nfs 3" to query NFS program
>> information on the Host_A, rpcinfo opens a tcp connection to query and
>> return sucessfully but the problem is after that the tcp port is in
>> TIME_WAITstate for 1 minutes. So during this 1 minutes, there is a
>> chance that another application opens the same port as the current
>> TIME_WAIT port, then it cannot start because the port is in TIME_WAIT
>> state.
>>
>> For example, rpcinfo opens tcp port 830 to query, then after that port
>> 830 goes to TIME_WAIT state. Later during that time, ssh netconfig
>> starts and use 830 (830 is NETCONF over SSH) -> fails to start with
>> the reason the port is in use.
>>
>> My question is if we have any ways to prevent this:
>>
>> 1. I found no option in rpcinfo command to specify tcp port to use when querying
>> 2. Change tcp_fin_timeout but it is not a good option
>> 3. Reserve 830 port by calling "nc" to listen on 830 port, then start
>> rpcinfo, after rpcinfo returns, we will the "nc" process". This option
>> has a limitation that we have to reserve all welknown ports before
>> calling rpcinfo, and we have to kill all "nc" process after rpcinfo
>> returns.
>>
>> Could you please let me know if we have any good way to avoid that?
>
> The problem is that rpcinfo is using the generic CLNT API of libtirpc,
> which uses bindresvport(3) under the hood. If the caller has the
> CAP_NET_BIND_SERVICE, bindresvport(3) will work and pick a reserved
> port at random, without consideration to whether the port is an
> IANA-assigned port.
>
> I have a patch that modifies bindresvport() to attempt to select a port
> that is not in /etc/services. I can post it here for you to try, let
> me know.
>
> You can try running rpcinfo as a regular user so that the CLNT API
> will pick an ephemeral port instead of a reserved port.
>
> Is it possible to give the rpcinfo executable a set of file
> capabilities that disables CAP_NET_BIND_SERVICE?
>
>
> --
> Chuck Lever
>
>
>
