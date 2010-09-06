From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] kernel panic
Date: Mon, 06 Sep 2010 22:25:13 +0300
Message-ID: <4C854019.6030108@panasas.com>
References: <4C80EC83.1030606@desy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:16749 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752575Ab0IFTZP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Sep 2010 15:25:15 -0400
In-Reply-To: <4C80EC83.1030606@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tigran, was there an actual panic or just this string of WARNINGs?
Were there any ill effects for this warning?
The reason I'm asking is that according to our latest analysis of the
code the warning might be a red herring and it can happen in valid scenarios
so we intend to remove it altogether in the revised pnfs-submit series.

Thanks for reporting in any case!

Benny

On 2010-09-03 15:39, Tigran Mkrtchyan wrote:
>   FYI
> 
> kernel pnfs-all-2.6.35-2010.08-24 (git 
> fa5a03da84b02026396be0736288b3f4a8143ff2)
> 
> 
> Regards,
>      Tigran.
> 
> 
> 
> _______________________________________________
> NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org
> instead.  (To subscribe to linux-nfs@vger.kernel.org: send "subscribe
> linux-nfs" in the body of a message to majordomo-u79uwXL29TaiAVqoAR/hOA@public.gmane.org)
> 
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs

