Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42769 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751348Ab2LRSuI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2012 13:50:08 -0500
Date: Tue, 18 Dec 2012 13:50:06 -0500
To: Keith Edmunds <kae@midnighthax.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS access slow
Message-ID: <20121218185006.GA14716@fieldses.org>
References: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 18, 2012 at 03:52:48PM +0000, Keith Edmunds wrote:
> Accessing disks locally on a server gives read speeds around 100MB/s,
> write speeds around 267MB/s.
> 
> Mounting the same disks on the same server via NFS (ie, not using the
> network at all) gives read speeds around 30MB/s, write speeds around
> 80MB/s.
> 
> That's about 30% of the local access speed.
> 
> Is that to be expected? I'd expect a 10-15% slowdown, but not this much.
> 
> This is using NFSv4; using NFSv3 improves the speeds slightly (36MB/s
> read, 95MB/s write).

What are your disks?  How exactly are you getting those numbers?
(Literally, step-by-step, what commands are you running?)

What kernel version?

Note loopback-mounts (client and server on same machine) aren't really
fully supported.

--b.

> 
> Other parameters we've changed, none of which have a significant impact:
> 
>  - UDP/TCP
>  - rsize and wsize
>  - noatime
>  - noacl
>  - nocto
> 
> If that's an unexpected slow down, where should we be looking?
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
