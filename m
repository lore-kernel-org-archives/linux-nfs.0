Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50643 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778Ab3JUOE0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 10:04:26 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
CC: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountstats: enforce new python syntax
Date: Mon, 21 Oct 2013 14:04:24 +0000
Message-ID: <D009ABC0-C071-4597-8B67-11C7A0486383@netapp.com>
References: <1382346241-20637-1-git-send-email-tigran.mkrtchyan@desy.de>
In-Reply-To: <1382346241-20637-1-git-send-email-tigran.mkrtchyan@desy.de>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I posted a similar patch last week.

-dros

On Oct 21, 2013, at 5:04 AM, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de> wrote:

> $ mountstats
>  File "/usr/sbin/mountstats", line 272
>    (count, ((count * 100) / sends)), end=' ')
>                                         ^
> SyntaxError: invalid syntax
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
> tools/mountstats/mountstats.py | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
> index 3f5fea5..351145e 100644
> --- a/tools/mountstats/mountstats.py
> +++ b/tools/mountstats/mountstats.py
> @@ -1,5 +1,6 @@
> #!/usr/bin/env python
> # -*- python-mode -*-
> +from __future__ import print_function
> """Parse /proc/self/mountstats and display it in human readable form
> """
> 
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

