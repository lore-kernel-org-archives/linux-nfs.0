From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/7] misc fixes and cleanup
Date: Fri, 01 Oct 2010 18:30:40 +0200
Message-ID: <4CA60CB0.20706@panasas.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40908 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750988Ab0JAQam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 12:30:42 -0400
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks. I'm merging all 7 and rebasing
so we can have a new tree before I fly out tomorrow morning.

Benny

On 2010-10-01 18:02, Fred Isaman wrote:
> The first 3 do some cleanup preparing for the hopefully final devinfo submission.
> 
> The last 3 fix some use of freed memory problems using the synch error handler (that
> were never being triggered because the asynch error handler got there first, at least
> until the LAYOUTGET code got restructured.)
> 
> Fred
>  
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
