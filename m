From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: bad filename
Date: Wed, 19 May 2010 13:29:04 -0400
Message-ID: <20100519172904.GC8137@fieldses.org>
References: <1634.192.168.105.97.1274289098.squirrel@192.168.103.210>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: linux-3F1zPYPlOzIFuQHM+6P7RA@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab0ESR3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 13:29:07 -0400
In-Reply-To: <1634.192.168.105.97.1274289098.squirrel-Q0ErXNX1RuZBGA/cGGHPPw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 19, 2010 at 02:11:38PM -0300, linux-3F1zPYPlOzIFuQHM+6P7RA@public.gmane.org wrote:
> Hello !
> 
> I have a nfs server on Fedora 11 , kernel 2.6.29 and nfs-utls
> 1.2.0-6.fc11, one of my clients is an old pc on DOS (I can't replace it
> now. In this client I can't see the correct name of my files. If the name
> is obje.rem I see obje&&00.
> In earlier version it worked well.

What was that earlier version?

Could we see a packet trace?

(So:

	run tcpdump -s0 -wtmp.pcap
	mount, and ls the directory with the problematic file.
	kill the tcpdump
	send us tmp.pcap.

)

--b.

> 
> Someone can help me ?
> 
> Thanks in advance
> 
> 
> Luisa
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
