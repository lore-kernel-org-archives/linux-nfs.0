Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:51412 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbeEROnf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 10:43:35 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: Conflict tcp port between rpcinfo and other applications
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
Date: Fri, 18 May 2018 10:43:31 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <494F9084-A5C6-42E4-B198-29747B5929FF@oracle.com>
References: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
To: Naruto Nguyen <narutonguyen2018@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 18, 2018, at 7:09 AM, Naruto Nguyen =
<narutonguyen2018@gmail.com> wrote:
>=20
> Hello everyone,
>=20
> When I use "rpcinfo -T tcp $Host_A nfs 3" to query NFS program
> information on the Host_A, rpcinfo opens a tcp connection to query and
> return sucessfully but the problem is after that the tcp port is in
> TIME_WAITstate for 1 minutes. So during this 1 minutes, there is a
> chance that another application opens the same port as the current
> TIME_WAIT port, then it cannot start because the port is in TIME_WAIT
> state.
>=20
> For example, rpcinfo opens tcp port 830 to query, then after that port
> 830 goes to TIME_WAIT state. Later during that time, ssh netconfig
> starts and use 830 (830 is NETCONF over SSH) -> fails to start with
> the reason the port is in use.
>=20
> My question is if we have any ways to prevent this:
>=20
> 1. I found no option in rpcinfo command to specify tcp port to use =
when querying
> 2. Change tcp_fin_timeout but it is not a good option
> 3. Reserve 830 port by calling "nc" to listen on 830 port, then start
> rpcinfo, after rpcinfo returns, we will the "nc" process". This option
> has a limitation that we have to reserve all welknown ports before
> calling rpcinfo, and we have to kill all "nc" process after rpcinfo
> returns.
>=20
> Could you please let me know if we have any good way to avoid that?

The problem is that rpcinfo is using the generic CLNT API of libtirpc,
which uses bindresvport(3) under the hood. If the caller has the
CAP_NET_BIND_SERVICE, bindresvport(3) will work and pick a reserved
port at random, without consideration to whether the port is an
IANA-assigned port.

I have a patch that modifies bindresvport() to attempt to select a port
that is not in /etc/services. I can post it here for you to try, let
me know.

You can try running rpcinfo as a regular user so that the CLNT API
will pick an ephemeral port instead of a reserved port.

Is it possible to give the rpcinfo executable a set of file
capabilities that disables CAP_NET_BIND_SERVICE?


--
Chuck Lever



