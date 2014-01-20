Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:62619 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301AbaATOzE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jan 2014 09:55:04 -0500
Received: by mail-pb0-f53.google.com with SMTP id md12so2062902pbc.26
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jan 2014 06:55:03 -0800 (PST)
Message-ID: <52DD38C0.9060906@fuckthenavy.net>
Date: Mon, 20 Jan 2014 14:54:56 +0000
From: Justus Ranvier <justusranvier@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linuxnfs <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 guest opens random ports
References: <52DC1926.10600@fuckthenavy.net> <94AFC682-E055-4BA5-8022-2674AFCA91C7@primarydata.com>
In-Reply-To: <94AFC682-E055-4BA5-8022-2674AFCA91C7@primarydata.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 01/19/2014 07:16 PM, Trond Myklebust wrote:
> On Jan 19, 2014, at 13:27, Justus Ranvier <justusranvier@gmail.com> wrote:
>
>> I have systems running Gentoo Linux mounting shares hosted on a Gentoo
>> Linux server. All are running 3.12.8 kernels and using NFS 4.
>>
>> I've followed all instructions I can find for fixing everything to a
>> static port, but I still see one instance ofrandom port behavior.
>>
>> A kernel process (does not display a PID in netstat) on the guests is
>> opening listening sockets on random high-numbered ports. The server is
>> attempting to contact those guests via random low-numbered ports, which
>> my firewall is blocking.
>>
>> Despite these packets being blocked, I haven't noticed any adverse
>> effects - everything appears to work normally except for my system logs
>> on the server being spammed with blocked outgoing connection attempts.
>>
>> What is this random port the client is trying to accept connections on,
>> and how do I make it listen on a fixed port instead of a random one so
>> that I can write useful firewall rules?
>>
> That’s probably the NFSv4 callback port. Please see your kernel Documentation/kernel-parameters.txt for how to set the nfs.callback_tcpport kernel/module option.
Thanks you, that was indeed the problem. I was able to set this port via
the kernel command line and resolve my firewalling difficulties.

I thought I'd be able to set that parameter via sysctl.conf, in the same
manner as sys.fs.nfs.nlm_tcpport and sys.fs.nfs.nlm_udpport, but that
method returns an error.

Would it be possible to make this port configurable in the same manner
as lock manager ports via sysctl, or as an explicit compile time option?
