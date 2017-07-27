Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43241 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751413AbdG0Rj0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 27 Jul 2017 13:39:26 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EB6AB496
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 17:39:25 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id BB7754D751
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 17:39:25 +0000 (UTC)
Subject: Re: [PATCH] mountstats: remove shebang
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170727144048.6062-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <aab53856-3b59-8b59-0f2e-e7fdfca1af46@RedHat.com>
Date: Thu, 27 Jul 2017 13:39:25 -0400
MIME-Version: 1.0
In-Reply-To: <20170727144048.6062-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/27/2017 10:40 AM, Steve Dickson wrote:
> There might be an issue that the script is executed with unwanted
> version of <lang>.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed... 

steved.
> ---
>  tools/mountstats/mountstats.py | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 88ccdae..a68d702 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -1,4 +1,4 @@
> -#!/usr/bin/env python
> +#!/usr/bin/python
>  # -*- python-mode -*-
>  """Parse /proc/self/mountstats and display it in human readable form
>  """
> 
