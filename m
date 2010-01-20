Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f42.google.com ([209.85.160.42]:46892 "EHLO
	mail-pw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab0ATPYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 10:24:52 -0500
Date: Wed, 20 Jan 2010 23:26:52 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
To: jin zhencheng <zhenchengjin@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        zhenchengjin@163.com
Subject: Re: nfs-error-RPC: multiple fragments per record not supported
Message-ID: <20100120152652.GA3595@hack>
References: <de04351e1001200320y2e763680gc7e3b20319c6386e@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <de04351e1001200320y2e763680gc7e3b20319c6386e@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 20, 2010 at 07:20:34PM +0800, jin zhencheng wrote:
>I use kernel 2.6.26.2
>
>I use  29 clients,
>
>every client mount parameters as this: mount -t nfs -o
>rw,noatime,v3,rsize=32768,wsize=32768,hard,intr,tcp,nolock
>
>my system have many errors lke these :
>
>RPC: multiple fragments per record not supported
>RPC: multiple fragments per record not supported
>RPC: fragment too large: 0x318c87ee
>RPC: multiple fragments per record not supported
>RPC: fragment too large: 0x78bdeedb
>RPC: multiple fragments per record not supported
>RPC: fragment too large: 0x75cf8a33
>RPC: fragment too large: 0x44764ada
>RPC: multiple fragments per record not supported
>RPC: fragment too large: 0x0a08e7c0
>RPC: multiple fragments per record not supported
>RPC: multiple fragments per record not supported
>RPC: fragment too large: 0x5b4e13a1
>RPC: fragment too large: 0x08351a9f
>

Does 'ethtool -K eth0 tso off' help?

-- 
Live like a child, think like the god.
 
