Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:40973 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757264Ab1DHBKC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2011 21:10:02 -0400
Message-ID: <4D9E6063.1020607@parallels.com>
Date: Thu, 7 Apr 2011 20:09:55 -0500
From: Rob Landley <rlandley@parallels.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: What's nlmsvc_proc_share() for?
References: <4D9C7916.5030907@parallels.com> <4D9D29A5.7000507@cn.fujitsu.com>
In-Reply-To: <4D9D29A5.7000507@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/06/2011 10:04 PM, Mi Jinlong wrote:
> Rob Landley:
>> What's this code for, and where does it get used?  Is it something out
>> of tree, or some header #define that's glued##together that I'm not
>> picking up via grep...?
> 
>   Maybe you can get some info from the following code at fs/lockd/svc4proc.c:
> 
>  462 
>  463 #define PROC(name, xargt, xrest, argt, rest, respsize)  \
>  464  { .pc_func     = (svc_procfunc) nlm4svc_proc_##name,   \
...
>  498   PROC(share,           shareargs,      shareres,       args,   res, Ck+St+1),

So it's glued##together in a macro.  Got it.

Thanks,

Rob
