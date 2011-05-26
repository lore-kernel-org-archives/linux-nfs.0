Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:54617 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932746Ab1EZTHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 15:07:35 -0400
Received: by gxk21 with SMTP id 21so411288gxk.19
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2011 12:07:34 -0700 (PDT)
Message-ID: <4DDEA4DE.9000108@umich.edu>
Date: Thu, 26 May 2011 15:07:10 -0400
From: Michael Groshans <groshans@umich.edu>
To: Upakul Barkakaty <upakul@gmail.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: IPv6 support for NFSv2 server.
References: <7C481A0A0BBE9E4BA110F26D7A2BFFDC026E7C46@nodmx01.igglobal.com>	<BANLkTikzuTGgHU=oUMTjmPhfsR_-nD5Ffw@mail.gmail.com>	<BANLkTi=s4_A-WiG_a11pLgmeQ39qw=22Hg@mail.gmail.com>	<CCEDE6F7-12A9-4308-A178-873FD972994C@oracle.com> <BANLkTi=_kAOipcotAH+vP-nHMebkrQqR7Q@mail.gmail.com>
In-Reply-To: <BANLkTi=_kAOipcotAH+vP-nHMebkrQqR7Q@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/26/2011 02:57 PM, Upakul Barkakaty wrote:
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
> 

Are you escaping the ipv6 address with brackets (e.g. mount -o vers=2
[aaaa:bbbb::cccc]:/path /mnt/point)?

-Mike Groshans
