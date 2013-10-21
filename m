Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753095Ab3JUOH3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 10:07:29 -0400
Message-ID: <52653549.1040501@RedHat.com>
Date: Mon, 21 Oct 2013 10:08:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] mountstats: fix python2.x support
References: <1382019434-12377-1-git-send-email-dros@netapp.com>
In-Reply-To: <1382019434-12377-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 17/10/13 10:17, Weston Andros Adamson wrote:
> Commit b703eabe4c4bc5c2d5fd9a07b6b995d67ea7e77a converted mountstats to using
> python3's print() function, but this doesn't work in python2.x without
> importing the print function from __future__.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
Committed...

steved.
> ---
>  tools/mountstats/mountstats.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 3f5fea5..e46105d 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -3,6 +3,8 @@
>  """Parse /proc/self/mountstats and display it in human readable form
>  """
>  
> +from __future__ import print_function
> +
>  __copyright__ = """
>  Copyright (C) 2005, Chuck Lever <cel@netapp.com>
>  
> 
