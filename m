From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs]ds ip
Date: Tue, 13 Jul 2010 11:32:01 +0300
Message-ID: <4C3C2481.1090708@panasas.com>
References: <AANLkTilJTogMkslFT-bGoOJYgGSznHnpi75e6IeCuWzC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pnfs <linux-nfs@vger.kernel.org>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:2480 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754096Ab0GMIcE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jul 2010 04:32:04 -0400
In-Reply-To: <AANLkTilJTogMkslFT-bGoOJYgGSznHnpi75e6IeCuWzC-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 13, 2010, 5:05 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> I use 
> #define dprintk printk

You don't have to modify the kernel to see the debug prints...
You can turn the debug prints on and off in run time
by writing the numeric bitmask (in ASCII) into /proc/sys/sunrpc/nfs_debug
for example:
# echo 32767 > /proc/sys/sunrpc/nfs_debug

> to show some messages in the pnfs process. In the pnfs process, the
> client would use some functions in nfs4filelayoutdev.c to connect with
> ds. But from the printk messages, I found that the functions that
> connect to the ds printk the ip message, which is belong to the mds. Do
> the client only connect to the mds? Do the mds become the storage server
> which connect to the client? This conficts the pnfs architecture.Please
> give me some answers. 

The client should communicate with the DS for I/O operations.
If the MSD has dual function, both as a DS and a MDS, the DS ip address
may be the same as the MDS's.

Can you give an example of a particular message you're worried about?

What do you have running on the server side?

Benny
