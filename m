Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.22]:50868 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S932451Ab2HHS0Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Aug 2012 14:26:25 -0400
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="utf-8"
Date: Wed, 08 Aug 2012 20:26:22 +0200
From: "Johannes Schild" <JSchild@gmx.de>
In-Reply-To: <20120808163916.GA24539@umich.edu>
Message-ID: <20120808182622.177380@gmx.net>
MIME-Version: 1.0
References: <20120808155829.177400@gmx.net> <20120808163916.GA24539@umich.edu>
Subject: Re: Blocklayout
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jim,

thanks for your fast reply. I applied the patch, but didnt changed. I got no Layout information on Wireshark. Only the output of blockmapd changed...


[root@Client2 sbin]# ./blkmapd -f
blkmapd: process_deviceinfo: 5 vols
blkmapd: decode_blk_volume: simple 0
blkmapd: decode_blk_volume: slice 1
blkmapd: decode_blk_volume: simple 2
blkmapd: decode_blk_volume: slice 3
blkmapd: process_deviceinfo: 5 vols
blkmapd: decode_blk_volume: simple 0
blkmapd: decode_blk_volume: slice 1
blkmapd: decode_blk_volume: simple 2
blkmapd: decode_blk_volume: slice 3

Any ideas?

Thanks

Johannes


> Johannes Schild wrote:
> 
>   on client-side i did the instructions from the howto. But the output
> from 
>   blkmpad looks a little bit curious:
> 
> Your blkmapd is out of date.  You need 0001-remove-pretty_sig.patch from
> the
> wiki.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
