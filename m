Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40693 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758195Ab1EZTIV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:08:21 -0400
Subject: Re: IPv6 support for NFSv2 server.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <BANLkTi=_kAOipcotAH+vP-nHMebkrQqR7Q@mail.gmail.com>
Date: Thu, 26 May 2011 15:08:10 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <098B91DC-B28B-4A7C-8816-14E633A370C0@oracle.com>
References: <7C481A0A0BBE9E4BA110F26D7A2BFFDC026E7C46@nodmx01.igglobal.com> <BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw@mail.gmail.com> <BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg@mail.gmail.com> <CCEDE6F7-12A9-4308-A178-873FD972994C@oracle.com> <BANLkTi=_kAOipcotAH+vP-nHMebkrQqR7Q@mail.gmail.com>
To: Upakul Barkakaty <upakul@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On May 26, 2011, at 2:57 PM, Upakul Barkakaty wrote:

> Hi Chuck,
> 
> Thanks for writing in. I am using the command line option -o vers=2.
> 
> These 2 commands return different errors:
> 
> mount -o vers=2 <ipv6-address>:<path> --> mount.nfs: an incorrect
> mount option was specified
> mount <ipv6-address>:<path> --> mount.nfs: system call failed
> 
> RHEL6 uses NFSv4 by default so the second command is expected to use NFSv4.
> 
> Both the above commands execute successfully in case of ipv4 addresses.

Those error messages are a bit confusing, aren't they.  Have you tried using the "proto=tcp6" mount option in either case?  Do you enclose the IPv6 addresses in square brackets?

What does "rpcinfo <ipv6-address>" say?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




