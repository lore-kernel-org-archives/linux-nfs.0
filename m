From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: get_lock_alloc_layout
Date: Thu, 01 Jul 2010 17:11:08 +0300
Message-ID: <4C2CA1FC.8060803@panasas.com>
References: <7B1AD6D8-4D7D-48B6-9439-7A1469784754@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org Mailing list" <linux-nfs@vger.kernel.org>
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:7176 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752896Ab0GAOLL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 10:11:11 -0400
In-Reply-To: <7B1AD6D8-4D7D-48B6-9439-7A1469784754@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 01, 2010, 16:50 +0300, Andy Adamson <andros@netapp.com> wrote:
> Hi Benny
> 
> Why do we have the complexity of waiting on a bit lock for allocating  
> a layout? Why can't we use the normal form:

It's possible but the expectation was that the race here would
not be infrequent enough it's worth (statistically) losing it.

Benny

> 
> take the i_lock
> lookup layout
> if (layout == NULL) {
>          give up i_lock
>          allocate and init new layout
>                 return NULL if allocation fails
>          take the i_lock
>          lookup layout
>          if (layout == NULL)
>                  set new layout for return
>          else
>                  set found layout for return
> }
> give up i_lock
> if new was allocated and not used
>            free the new layout
> return layout
> 
> 
> -->Andy
> 
>   
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
