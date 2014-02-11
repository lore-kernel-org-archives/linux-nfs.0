Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41141 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831AbaBKOge (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Feb 2014 09:36:34 -0500
Date: Tue, 11 Feb 2014 09:36:33 -0500
To: "McAninley, Jason" <jmcaninl@harris.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question regard NFS 4.0 buffer sizes
Message-ID: <20140211143633.GB9918@fieldses.org>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 11, 2014 at 12:32:33PM +0000, McAninley, Jason wrote:
> I'm looking for detailed documentation regarding some of the innards of NFS 4.0, without necessarily having to read through the source code (if such documentation exists). 
> 
> Specifically related to the relationship between NFS's rsize/wsize options versus some of the lower-level networking buffers. Buffer parameters that I have come across (and my current settings) include:
> 
>   - sysctl's net.core.{r,w}mem_default: 229376
>   - sysctl's net.core.{r,w}mem_max:     131071
>   - sysctl's net.ipv4.tcp_{r,w}mem      4096 87380 4194304
>   - #define RPCSVC_MAXPAYLOAD          (1*1024*1024u)
> 
> When I run Wireshark during an NFS transfer, I see MAX{READ,WRITE} attributes returned from GETATTR with the value of 1MB. I'm guessing this corresponds to the limit set by RPCSVR_MAXPAYLOAD? However, the maximum packet size I'm recording in practice is ~32K.

Are you using UDP or TCP?

And what do you mean by "maximum packet size"?

To see if the maximum rsize/wsize is being used you'd need to look for
the length of the data in a READ reply or WRITE call.

What actual problem are you trying to solve?  (Is your read or write
bandwidth lower than you expected?)

--b.

> 
> In fact, it seems like regardless of the change to {r,w}size (I've tried 32K, 64K, 128K) I am not seeing changes in the max packet size.
> 
> This is leading me to investigate the buffer sizes on the client/server. My thought is that if a buffer exists that is too small, NFS/Kernel will ship a packet prior to reaching the MAXWRITE size. 
> 
> Any input is appreciated.
> 
> -Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
