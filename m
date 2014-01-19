Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:55558 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699AbaASTQc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Jan 2014 14:16:32 -0500
Received: by mail-ie0-f174.google.com with SMTP id tp5so1127410ieb.19
        for <linux-nfs@vger.kernel.org>; Sun, 19 Jan 2014 11:16:31 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFSv4 guest opens random ports
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <52DC1926.10600@fuckthenavy.net>
Date: Sun, 19 Jan 2014 14:16:29 -0500
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <94AFC682-E055-4BA5-8022-2674AFCA91C7@primarydata.com>
References: <52DC1926.10600@fuckthenavy.net>
To: Justus Ranvier <justusranvier@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 19, 2014, at 13:27, Justus Ranvier <justusranvier@gmail.com> wrote:

> I have systems running Gentoo Linux mounting shares hosted on a Gentoo
> Linux server. All are running 3.12.8 kernels and using NFS 4.
> 
> I've followed all instructions I can find for fixing everything to a
> static port, but I still see one instance ofrandom port behavior.
> 
> A kernel process (does not display a PID in netstat) on the guests is
> opening listening sockets on random high-numbered ports. The server is
> attempting to contact those guests via random low-numbered ports, which
> my firewall is blocking.
> 
> Despite these packets being blocked, I haven't noticed any adverse
> effects - everything appears to work normally except for my system logs
> on the server being spammed with blocked outgoing connection attempts.
> 
> What is this random port the client is trying to accept connections on,
> and how do I make it listen on a fixed port instead of a random one so
> that I can write useful firewall rules?
> 

That’s probably the NFSv4 callback port. Please see your kernel Documentation/kernel-parameters.txt for how to set the nfs.callback_tcpport kernel/module option.

--
Trond Myklebust
Linux NFS client maintainer

