Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og102.obsmtp.com ([64.18.0.143]:59653 "HELO
	exprod5og102.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751337Ab0JGPcj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 11:32:39 -0400
Message-ID: <4CADE816.5050405@panasas.com>
Date: Thu, 07 Oct 2010 11:32:38 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/4] pnfs-submit: misc fixes in CB_LAYOUTRECALL and layout
 stateid code
References: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286397317-17881-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Merged all 4 patches (with my fix to patch 2/4)
And pushed to the local Bakeathon server:
git://192.168.12.138/bhalevy/linux-pnfs.git

Benny

 Thanks!
On 2010-10-06 16:35, Fred Isaman wrote:
> Preparing for second submission wave, here are some misc fixes to the
> LAYOUTRETURN and callback code, that all apply to the top of Benny's
> pnfs-submit branch
> 
> Fred
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
