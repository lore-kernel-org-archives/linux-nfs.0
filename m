From: jin zhencheng <zhenchengjin@gmail.com>
Subject: Re: nfs-error-RPC: multiple fragments per record not supported
Date: Fri, 22 Jan 2010 11:07:23 +0800
Message-ID: <de04351e1001211907m4ff30a24ubf338fbd0bd1d086@mail.gmail.com>
References: <de04351e1001200320y2e763680gc7e3b20319c6386e@mail.gmail.com>
	 <20100120152652.GA3595@hack>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	zhenchengjin-9Onoh4P/yGk@public.gmane.org
To: =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:48278 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755917Ab0AVDHY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jan 2010 22:07:24 -0500
In-Reply-To: <20100120152652.GA3595@hack>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have tried  'ethtool -K eth0 tso off' ,but my system also have  the
same errors

do someone know how to resolve  ?

RPC: multiple fragments per record not supported
RPC: multiple fragments per record not supported
RPC: fragment too large: 0x318c87ee
RPC: multiple fragments per record not supported



On Wed, Jan 20, 2010 at 11:26 PM, Am=E9rico Wang <xiyou.wangcong@gmail.=
com> wrote:
> On Wed, Jan 20, 2010 at 07:20:34PM +0800, jin zhencheng wrote:
>>I use kernel 2.6.26.2
>>
>>I use =A029 clients,
>>
>>every client mount parameters as this: mount -t nfs -o
>>rw,noatime,v3,rsize=3D32768,wsize=3D32768,hard,intr,tcp,nolock
>>
>>my system have many errors lke these :
>>
>>RPC: multiple fragments per record not supported
>>RPC: multiple fragments per record not supported
>>RPC: fragment too large: 0x318c87ee
>>RPC: multiple fragments per record not supported
>>RPC: fragment too large: 0x78bdeedb
>>RPC: multiple fragments per record not supported
>>RPC: fragment too large: 0x75cf8a33
>>RPC: fragment too large: 0x44764ada
>>RPC: multiple fragments per record not supported
>>RPC: fragment too large: 0x0a08e7c0
>>RPC: multiple fragments per record not supported
>>RPC: multiple fragments per record not supported
>>RPC: fragment too large: 0x5b4e13a1
>>RPC: fragment too large: 0x08351a9f
>>
>
> Does 'ethtool -K eth0 tso off' help?
>
> --
> Live like a child, think like the god.
>
>
