Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:37744 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750882AbeERQrA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 12:47:00 -0400
Subject: Re: Conflict tcp port between rpcinfo and other applications
To: Naruto Nguyen <narutonguyen2018@gmail.com>,
        linux-nfs@vger.kernel.org
References: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
From: Manjunath Patil <manjunath.b.patil@oracle.com>
Message-ID: <d12b60fa-de29-1d40-80f0-fa0e30957f55@oracle.com>
Date: Fri, 18 May 2018 09:46:56 -0700
MIME-Version: 1.0
In-Reply-To: <CANpxKHFczD0v7O39zzR_dyOYEV7n5bwjJmEQxLnNuxf4HHJCqQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/18/2018 4:09 AM, Naruto Nguyen wrote:

> Hello everyone,
>
> When I use "rpcinfo -T tcp $Host_A nfs 3" to query NFS program
> information on the Host_A, rpcinfo opens a tcp connection to query and
> return sucessfully but the problem is after that the tcp port is in
> TIME_WAITstate for 1 minutes. So during this 1 minutes, there is a
> chance that another application opens the same port as the current
> TIME_WAIT port, then it cannot start because the port is in TIME_WAIT
> state.
>
> For example, rpcinfo opens tcp port 830 to query, then after that port
> 830 goes to TIME_WAIT state. Later during that time, ssh netconfig
> starts and use 830 (830 is NETCONF over SSH) -> fails to start with
> the reason the port is in use.
>
> My question is if we have any ways to prevent this:
>
> 1. I found no option in rpcinfo command to specify tcp port to use when querying
> 2. Change tcp_fin_timeout but it is not a good option
> 3. Reserve 830 port by calling "nc" to listen on 830 port, then start
> rpcinfo, after rpcinfo returns, we will the "nc" process". This option
> has a limitation that we have to reserve all welknown ports before
> calling rpcinfo, and we have to kill all "nc" process after rpcinfo
> returns.
>
> Could you please let me know if we have any good way to avoid that?
If not already done, enable tcp_timestamps [echo 1 > 
/proc/sys/net/ipv4/tcp_timestamps]
This should make re-use of TIME_WAIT socket earlier than 60 seconds.

I found this online - https://tools.ietf.org/html/rfc6191
>
> Thanks a lot,
>
> Brs,
> Naruto
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

