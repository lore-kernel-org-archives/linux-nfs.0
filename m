Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:48062 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754248AbdHYDVf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Aug 2017 23:21:35 -0400
Subject: Re: No option for client bind address in NFS?
To: Lukas Erlacher <erlacher@in.tum.de>, linux-nfs@vger.kernel.org
References: <7830cf28-5753-ddd5-339c-497e2ad6a10c@in.tum.de>
From: Ben Greear <greearb@candelatech.com>
Message-ID: <040f1042-d6c8-d73b-a1b1-250e33f6bd1c@candelatech.com>
Date: Thu, 24 Aug 2017 20:21:33 -0700
MIME-Version: 1.0
In-Reply-To: <7830cf28-5753-ddd5-339c-497e2ad6a10c@in.tum.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 08/24/2017 07:14 PM, Lukas Erlacher wrote:
> [Note: I accidentally sent this to linux-kernel initially due to a misclick. Sorry for that.]
>
> Hello,
>
> after reading the NFS(5) manpage and doing some searching through the mailing list archive (of course, due to it being ubiquitous in posted logs, searching for "addr" and "clientaddr" was a bit hopeless) I have come to conclude that NFS does not have an option for explicitly specifying an address for the client socket to bind to.
>
> This is problematic for my usecase, which is "securing" NFS shares by exporting them to specific client hostnames only.
>
> Most of my NFS client machines have multiple IP addresses and since configuring IP addresses and routes on debian-ish systems can be quite an art, I don't want to trust on the default route going via the correct IP so that the NFS server recognizes the host; I also don't want to go to the effort of having the shares exported to every possible IP that might be configured on the client.
>
> Most utilities (e.g. ping, dig) have an option to specify an explicit client socket bind address.
>
> Why doesn't NFS have that? (As I understand it, the clientaddr option firstly is only interpreted by NFSv4 and secondly, is not the bind address but only used by the server for callbacks)
>
> For reference, my NFS server are Ubuntu 14.04/16.04 VMs using the nfs-kernel-server package, as well as Solaris machines using the "sharenfs" option on ZFS pools; my clients are Ubuntu 14.04/16.04 VMs using nfs-common package.
>
> Best,
>
> Lukas Erlacher
> RBG Systemgruppe
> Rechnerbetriebsgruppe der Fakultäten Informatik und Mathematik
> Technische Universität München

I've posted patches in the past to add this feature, and they are currently in my
kernels.  Would love to see them upstream, but there was no interest in the past.

https://github.com/greearb

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
