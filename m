Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753293AbaKLS5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Nov 2014 13:57:21 -0500
Message-ID: <5463AD87.20305@RedHat.com>
Date: Wed, 12 Nov 2014 13:57:11 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: bstroesser@ts.fujitsu.com, neilb@suse.de, linux-nfs@vger.kernel.org
CC: bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 0/3] rpc.mountd: fix some vulnerabilities
References: <d6437a$6ag11f@dgate10u.abg.fsc.net>
In-Reply-To: <d6437a$6ag11f@dgate10u.abg.fsc.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/05/2014 03:21 PM, bstroesser@ts.fujitsu.com wrote:
> Hello,
> 
> I'm sending a small set of 3 patches for a problem, that I have
> reported a few weeks ago.
> rpc.mountd can be blocked by a bad client, that sends lots of
> RPC requests, but never reads the replies from the socket either
> intentionally or e.g. caused by a wrong configured MTU.
> 
> While looking for a possible solution, I found another weakness
> in rpc.mountd if it is used "multithreaded" (-t nn).
> 
> The first two patches fix that weakness in the case of !HAVE_LIBTIRPC
> and HAVE_LIBTIRPC.
> The third patch more a kind of suggestion how the main problem could
> be fixed. I don't know whether we can set MAXREC without causing
> new troubles. When this patch is used, a  further patch for libtirpc
> also should be used. You can find it here:
>     http://sourceforge.net/p/libtirpc/mailman/libtirpc-devel/?viewmonth=201409
After applying all three patches, the DOS does stop... All three committed! 
Nice work! Thank you... very much!!

steved. 

> 
> Best regards,
> Bodo
> N‹§²æìr¸›yúèšØb²X¬¶Ç§vØ^–)Þº{.nÇ+‰·¥Š{±û"žØ^n‡r¡ö¦zËëh™¨è­Ú&¢ø®G«éh®(­éšŽŠÝ¢j"ú¶m§ÿïêäz¹Þ–Šàþf£¢·hšˆ§~ˆmml==
> 
