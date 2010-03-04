Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45990 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756206Ab0CDQ7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Mar 2010 11:59:24 -0500
Message-ID: <4B8FE6C7.2090207@oracle.com>
Date: Thu, 04 Mar 2010 11:58:47 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
CC: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] SUNRPC connect timeout case network request delay
References: <4B8F87A2.5080509@cn.fujitsu.com>
In-Reply-To: <4B8F87A2.5080509@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 03/04/2010 05:12 AM, Mi Jinlong wrote:
> Hi,
>
> When I use the nfs at RHEL with kernel-2.6.31 and nfs-utils-1.2.0,
> I got a problem, but i don't sure.
>
> The process:
>
> Step1: [22:40:9] Open file /mnt/nfs/file(OK)
> Step2: [22:40:9] Lock file
>         [22:40:9] Lock file success
> Step3: [22:40:9] Reboot the nfs server
>         If reboot success, put<enter>  to continue
> Step4: [22:42:16] Write data to file
>         [22:42:16] Write data success
> Step5: [22:42:16] Unlock file
>         [22:46:30] Unlock file success.
> Step6: [22:46:30] Close file /mnt/nfs/file
>         [22:46:30] Close fiel /mnt/nfs/file success
>
> The problem is at step5, unlock file takes 4 min, it's a long time than expected.
> When traceing the kernel, I find SUNRPC call call_connect timeout many times,
> one timeout is 1min.

The kernel's TCP reconnect logic will retry until it succeeds, without 
letting the upper level make progress.  For some reason, it is having 
difficulty reconnecting with your server.

> I think it's a problem of kernel, but i don't know why, can someone help me ?

# sudo rpcdebug -m rpc -s xprt trans

run your test, and then look in your kernel log.  It might tell you what 
error is occurring.  Another good thing to do is capture a network trace 
with

# sudo tcpdump -s 1540 -w /tmp/raw

while you run your test.

This is similar to the symptoms of other connect problems I've 
encountered recently.

-- 
chuck[dot]lever[at]oracle[dot]com
