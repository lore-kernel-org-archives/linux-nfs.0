From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfsd: default to kernel default for minorversion 1
Date: Thu, 18 Feb 2010 07:07:23 -0500
Message-ID: <4B7D2D7B.7010007@RedHat.com>
References: <1264631166-21898-1-git-send-email-bfields@citi.umich.edu> <1264631166-21898-2-git-send-email-bfields@citi.umich.edu> <20100201195821.GB19418@fieldses.org> <4B6B480C.1050307@RedHat.com> <20100205161001.GB24926@fieldses.org> <20100205192859.GE24926@fieldses.org> <20100205200501.GA28483@fieldses.org> <4B75B2DF.9060005@RedHat.com> <20100212200548.GB23361@fieldses.org> <4B75CBA3.8010001@RedHat.com> <20100212215524.GF24661@fieldses.org> <4B7C47A2.4010100@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757583Ab0BRMH0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2010 07:07:26 -0500
In-Reply-To: <4B7C47A2.4010100-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/17/2010 02:46 PM, Steve Dickson wrote:
> The fact there needed to be yet another code change to
> re-enabled the 4.1 functionality bother me... So This
> patch basically does the same as your patch, does not
> write "+4.1" to the versions file. But it also introduces
> a configuration variable that will allow us to re-enabled
> the functionality w/out changing any code...
> 
> BTW, there was precedence with adding this type of 
> configuration variable since there has been
> NFS3_SUPPORTED and NFS4_SUPPORTED variables in the 
> past.
> 
> steved.
> 
> commit 6d5ac3fa75024be569b458f4d9b6ce05be47f601
> Author: Steve Dickson <steved@redhat.com>
> Date:   Wed Feb 17 14:38:19 2010 -0500
> 
>     nfsd: Disble NFS 4.1 functionality by default
>     
>     Due to the fact the current kernel code do not completely
>     conform to the NFS 4.1 RFC, this patch disable the 4.1 support
>     on the server.
>     
>     To control this 41 functionality, the NFS41_SUPPORTED
>     configuration variable now exist that will allow us to
>     re enable the functionality  without any code changes.
Committed...

steved.
