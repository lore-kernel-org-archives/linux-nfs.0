Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:52012 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbeEST3D (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 19 May 2018 15:29:03 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Conflict tcp port between rpcinfo and other applications
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANpxKHHg2yrtWqZiM+Hnz+GgpaPyCW8ZmJ6OsGKdpBt9qgM+fA@mail.gmail.com>
Date: Sat, 19 May 2018 15:28:58 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A292CF59-A2F5-4FC9-8083-9EDBA175742E@oracle.com>
References: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
 <494F9084-A5C6-42E4-B198-29747B5929FF@oracle.com>
 <CANpxKHHg2yrtWqZiM+Hnz+GgpaPyCW8ZmJ6OsGKdpBt9qgM+fA@mail.gmail.com>
To: Naruto Nguyen <narutonguyen2018@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 19, 2018, at 5:07 AM, Naruto Nguyen =
<narutonguyen2018@gmail.com> wrote:
>=20
> Hi Chuck,
>=20
> Thanks for your reply.
>=20
> Yep, could you please post your patch here?

I will post in a separate thread. This is a patch to libtirpc, so
you will have to build and install that, then build and install
rpcinfo. You are using a distribution with libtirpc, right?

It is a new and experimental patch, so it might need some additional
debugging. Thanks for helping test.


> You mean that after I
> applied your patch and running rpcinfo as a regular user, the CLNT API
> will pick a dynamic port instead of reserved port, right?

That would be ideal, but that is not the case because of backwards
compatibility concerns.

With the patch, when the CNLT API consumer has CAP_NET_BIND_SERVICE
(for example, the consumer is a root user) bindresvport(3) will
attempt to choose a reserved port that is not assigned to a service
in /etc/services. If there are no such ports available, it will
choose a reserved port that does in appear in /etc/services.

Thus with the patch, rpcinfo running as root will use a reserved
port, but it will try to avoid the use of any port that is
registered in /etc/services.

I don't know of a reason why rpcinfo needs to use a reserved port.
The use of a reserved port in this case is simply an undocumented
behavior of the glibc and current libtirpc CLNT API.

The benefit of the patch is that once all CLNT API consumers are
rebuilt with this version of libtirpc, they will all try to avoid
reserved ports that are in /etc/services, even if they run as root.

The downside is that it isn't a 100% reliable solution: a possible
collision can still occur with an assigned reserved port if there
are no other reserved ports available.


> or without
> your patch, if I run as a normal user instead of root, rpcinfo will
> pick dynamic port instead of reserve port?

With or without the patch, running rpcinfo as a normal user should
be enough to cause it to use an ephemeral port.


> "Is it possible to give the rpcinfo executable a set of file
> capabilities that disables CAP_NET_BIND_SERVICE?"
>=20
> Could you please explain more how to disable CAP_NET_BIND_SERVICE?
> that's look good as well.

This solution should select an ephemeral port rather than a reserved
port, even when it is invoked by a root user. Start with "man setcap".

Note that I haven't tried this, and it requires that the file system
where the rpcinfo executable is stored supports file capabilities,
so if it resides on NFS for instance, this won't work at all.


> Thanks,
> Brs,
> Bao
>=20
> On 18 May 2018 at 21:43, Chuck Lever <chuck.lever@oracle.com> wrote:
>>=20
>>=20
>>> On May 18, 2018, at 7:09 AM, Naruto Nguyen =
<narutonguyen2018@gmail.com> wrote:
>>>=20
>>> Hello everyone,
>>>=20
>>> When I use "rpcinfo -T tcp $Host_A nfs 3" to query NFS program
>>> information on the Host_A, rpcinfo opens a tcp connection to query =
and
>>> return sucessfully but the problem is after that the tcp port is in
>>> TIME_WAITstate for 1 minutes. So during this 1 minutes, there is a
>>> chance that another application opens the same port as the current
>>> TIME_WAIT port, then it cannot start because the port is in =
TIME_WAIT
>>> state.
>>>=20
>>> For example, rpcinfo opens tcp port 830 to query, then after that =
port
>>> 830 goes to TIME_WAIT state. Later during that time, ssh netconfig
>>> starts and use 830 (830 is NETCONF over SSH) -> fails to start with
>>> the reason the port is in use.
>>>=20
>>> My question is if we have any ways to prevent this:
>>>=20
>>> 1. I found no option in rpcinfo command to specify tcp port to use =
when querying
>>> 2. Change tcp_fin_timeout but it is not a good option
>>> 3. Reserve 830 port by calling "nc" to listen on 830 port, then =
start
>>> rpcinfo, after rpcinfo returns, we will the "nc" process". This =
option
>>> has a limitation that we have to reserve all welknown ports before
>>> calling rpcinfo, and we have to kill all "nc" process after rpcinfo
>>> returns.
>>>=20
>>> Could you please let me know if we have any good way to avoid that?
>>=20
>> The problem is that rpcinfo is using the generic CLNT API of =
libtirpc,
>> which uses bindresvport(3) under the hood. If the caller has the
>> CAP_NET_BIND_SERVICE, bindresvport(3) will work and pick a reserved
>> port at random, without consideration to whether the port is an
>> IANA-assigned port.
>>=20
>> I have a patch that modifies bindresvport() to attempt to select a =
port
>> that is not in /etc/services. I can post it here for you to try, let
>> me know.
>>=20
>> You can try running rpcinfo as a regular user so that the CLNT API
>> will pick an ephemeral port instead of a reserved port.
>>=20
>> Is it possible to give the rpcinfo executable a set of file
>> capabilities that disables CAP_NET_BIND_SERVICE?


--
Chuck Lever



