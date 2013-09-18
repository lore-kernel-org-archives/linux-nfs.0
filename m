Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44115 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047Ab3IRTP0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Sep 2013 15:15:26 -0400
Message-ID: <5239FBE3.3020107@RedHat.com>
Date: Wed, 18 Sep 2013 15:15:47 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Harshula Jayasuriya <harshula@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsiostat: periodically flush stdout
References: <1378747050.4117.122.camel@serendib>
In-Reply-To: <1378747050.4117.122.camel@serendib>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/09/13 13:17, Harshula Jayasuriya wrote:
> * In a shell script, when nfsiostat is run in the background with
>   stdout redirected to a file, flush stdout periodically to ensure
>   that we do not lose the buffered output if the nfsiostat process 
>   is killed.
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
Committed!

steved.

> ---
>  tools/nfs-iostat/nfs-iostat.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
> index c035537..155581c 100644
> --- a/tools/nfs-iostat/nfs-iostat.py
> +++ b/tools/nfs-iostat/nfs-iostat.py
> @@ -413,6 +413,8 @@ class DeviceData:
>              self.__print_rpc_op_stats('WRITE', sample_time)
>              self.__print_page_stats(sample_time)
>  
> +        sys.stdout.flush()
> +
>  #
>  # Functions
>  #
> 
