Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34671 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757568Ab1ANEBt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 23:01:49 -0500
Received: by fxm20 with SMTP id 20so2397391fxm.19
        for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 20:01:47 -0800 (PST)
In-Reply-To: <4D2FB6F4.6070304@cn.fujitsu.com>
References: <AANLkTin04TeswNAM89ij84YzfeTAR7rsppGyZFfq01qM@mail.gmail.com>
	<4D2FB6F4.6070304@cn.fujitsu.com>
Date: Fri, 14 Jan 2011 15:01:47 +1100
Message-ID: <AANLkTin8PEyLqpdaTorSrS3Zi5sF7VeJRcrCVK9fEyc7@mail.gmail.com>
Subject: Re: mac error
From: hce <webmail.hce@gmail.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for your response. I've just found that nlockmgr did not
respond when I run following command on the server. Is it a problem or
it is normal? Anyway, the NFS is still working fine.

$ rpcinfo -t linux_server nlockmgr
rpcinfo: RPC: Timed out
program 100021 version 0 is not available

$ rpcinfo -u linux_server nlockmgr
rpcinfo: RPC: Timed out
program 100021 version 0 is not available

$ rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    895  status
    100024    1   tcp    898  status
    100011    1   udp    806  rquotad
    100011    2   udp    806  rquotad
    100011    1   tcp    809  rquotad
    100011    2   tcp    809  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100021    1   udp  32794  nlockmgr
    100021    3   udp  32794  nlockmgr
    100021    4   udp  32794  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   tcp  57164  nlockmgr
    100021    3   tcp  57164  nlockmgr
    100021    4   tcp  57164  nlockmgr
    100005    1   udp    828  mountd
    100005    1   tcp    831  mountd
    100005    2   udp    828  mountd
    100005    2   tcp    831  mountd
    100005    3   udp    828  mountd
    100005    3   tcp    831  mountd

On Fri, Jan 14, 2011 at 1:37 PM, Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
>
>
> hce :
>> Hi,
>>
>> I am running nfs server on a CentOS 5, it works fine for all
>> connections from linux, windows clients. Mac clients worked fine for
>> coping some regular files, but it could not copy mac packaging file
>> with the extension *.dmg, it stuck with an error "nfs server lockd not
>> responding", at the same time the server got a log message of
>> "rpc.statd[2448]: Can't callback linux_server (100021,4), giving up".
>>
>> Appreciate advice what could cause that problem and how could fix it?
>
> Hi hce,
>
> You use NFSv3,
> the NFSv3's file lock service depend on NLM(Network Lock Manager),
> that need a user space program named rpc.statd to support service
> like this:
>
>           |     nfs client     |      nfs server
> -------------------------------------------------
>           |                    |
> user space |     rpc.statd    <--->      rpc.statd
>           |        ^           |            ^
> --------------------|------------------------|----
>           |        v           |            v
> kernel     |      lockd       <--->       lockd
>
> when your nfs client is a MAC, maybe Mac's user space don't support
> a program as rpc.statd, or you don't make the program run correctly.
>
> Maybe you can use NFSv4 to avoid this problem.
>
>
> --
> ----
> thanks
> Mi Jinlong
>
>
