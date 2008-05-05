From: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Mon, 05 May 2008 05:20:21 +0100
Message-ID: <481E8B05.8000301@kingswood-consulting.co.uk>
References: <20080504223934.GA11746@vinvin.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org,
	public-bfields-uC3wQj2KruNg9hUCZPvPmw-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:55711 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbYEEEUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 00:20:33 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JssBi-0007fP-80
	for linux-nfs@vger.kernel.org; Mon, 05 May 2008 04:20:30 +0000
Received: from 202.55.46.103 ([202.55.46.103])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 04:20:30 +0000
Received: from frank by 202.55.46.103 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 04:20:30 +0000
In-Reply-To: <20080504223934.GA11746-CCKDRK/Hd0cdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

vincent wrote:
> I have the same problem than Frank, using NFS through a ssh tunnel. It
> was working with 2.6.20 and I've just upgraded to 2.6.25 and it does not
> works anymore.

Chuck sent me a workaround. The kernel understands an option that is not 
present in the userland mount code, mountproto. Set that along with the 
other options, so -o tcp,mountproto=tcp,... and it will force the mount 
call to go over tcp too.

Alternatively, you can grab the source for mount.nfs and disable 
text-based mounts by setting string=0, or by changing the kernel version 
it tests for to >2.6.25.

I think a fix for the kernel is in the works, so that should appear by 
2.6.26 and possibly for a 2.6.25.y too.

Frank

