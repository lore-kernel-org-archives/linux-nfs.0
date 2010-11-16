Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:43487 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab0KPUYI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2010 15:24:08 -0500
Subject: Re: Strange rpc.svcgssd behavior
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20101116201753.GB4482@merit.edu>
Date: Tue, 16 Nov 2010 15:22:04 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <577C5BE5-DB69-48E2-9E99-26ACE90C96BF@oracle.com>
References: <1C8B051A-5DC1-4871-B9B9-96E571036A9B@oracle.com> <4CE2AA3B.6070302@openoffice.nl> <4CE2DF2D.9070603@blub.net> <20101116201753.GB4482@merit.edu>
To: Jim Rees <rees@umich.edu>, Valentijn Sessink <valentyn@blub.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 16, 2010, at 3:17 PM, Jim Rees wrote:

> Valentijn Sessink wrote:
> 
>  Quoting myself: ...
>  Op 16-11-10 16:58, Valentijn Sessink schreef:
>> We have been disabling NM for years now because of this.
>>> Now I reboot, and NetworkManager happily adds "your.host	your" back to the "::1" entry, and rpc.svcgssd fails again.
> 
>  ... here's the long standing bug report for Ubuntu:
>  https://bugs.launchpad.net/ubuntu/+source/network-manager/+bug/8980
> 
>  (Been there since 2004). Nobody uses hostnames anymore, I guess ;)
> 
> It corrupts your resolv.conf too.  You should always remove Network Manager
> except on mobile hosts that really need it.

Before we go too far down the NM path of no return, I was under the impression that some applications require the host's name on the localhost entries in /etc/hosts.  That's why NM puts it there.

There's nothing invalid about having a hostname on the localhost entries in /etc/hosts, is there?

So I wonder if removing NM is really the solution here.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


