Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21132 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932711Ab0ECPOC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 11:14:02 -0400
Message-ID: <4BDEE809.8060501@oracle.com>
Date: Mon, 03 May 2010 11:13:13 -0400
From: Chuck Lever <chuck.lever@oracle.com>
To: ftn768@gmail.com
CC: Jack Byer <ojbyer@usa.net>, linux-nfs@vger.kernel.org
Subject: Re: IPv6 and NFS4
References: <544oecoS23680S01.1272897953@web01.cms.usa.net>
In-Reply-To: <544oecoS23680S01.1272897953@web01.cms.usa.net>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/03/2010 10:45 AM, Jack Byer wrote:
> If I have an NFS4 server successfully sharing a directory with a client and
> both machines have valid IPv4 and IPv6 addresses should it be possible to
> mount the directory using either IPv4 or IPv6?

Yes, that should work if nfs-utils-1.2.2 is built with --enable-tirpc 
and --enable-ipv6.

> Both machines are running 2.6.34-rc6 kernels, nfs-utils-1.2.2,
> libtirpc-0.2.0 and rpcbind-0.2.0. Mounting over IPv4 works perfectly, but
> IPv6 just times out while trying to mount the share. Using tcpdump I see
> that the two machines exchange 40 packets before the client finally gives
> up. There are no messages generated in the system log or dmesg of either
> machine.

Are the IPv6 addresses correctly registered with DNS?  Have you tried 
"mount.nfs4 ... -v" ?  Or:

$ sudo rpcdebug -m nfs -s mount

will produce more syslogging.

-- 
chuck[dot]lever[at]oracle[dot]com
