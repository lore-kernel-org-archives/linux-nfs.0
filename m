Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33314 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750732AbeC2QrD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Mar 2018 12:47:03 -0400
Date: Thu, 29 Mar 2018 12:47:02 -0400
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: Kernel NFS List <linux-nfs@vger.kernel.org>,
        "'J. Bruce Fields'" <bfields@redhat.com>
Subject: Re: [pynfs] [PATCH 2/3] Remove ganesha tag from DSESS9002 and
 DSESS9003
Message-ID: <20180329164702.GC17806@fieldses.org>
References: <00e301d3c6e9$76f406e0$64dc14a0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00e301d3c6e9$76f406e0$64dc14a0$@mindspring.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2018 at 04:06:54PM -0700, Frank Filz wrote:
> These tests actually require operational delegations which are not
> 
> generally available in Ganesha. With the fixedup tests, they now
> 
> hang without delegation support.

OK, thanks.--b.

> 
>  
> 
> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> 
> ---
> 
> nfs4.1/server41tests/st_destroy_session.py | 4 ++--
> 
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
>  
> 
> diff --git a/nfs4.1/server41tests/st_destroy_session.py
> b/nfs4.1/server41tests/st_destroy_session.py
> 
> index c247434..c48d144 100644
> 
> --- a/nfs4.1/server41tests/st_destroy_session.py
> 
> +++ b/nfs4.1/server41tests/st_destroy_session.py
> 
> @@ -39,7 +39,7 @@ def testDestroy2(t, env):
> 
>       tests for example)
> 
>     - check that we get the callback
> 
> -    FLAGS: destroy_session ganesha
> 
> +    FLAGS: destroy_session
> 
>      CODE: DSESS9002
> 
>      """
> 
>      recall = threading.Event()
> 
> @@ -88,7 +88,7 @@ def testDestroy3(t, env):
> 
>     - check that a new callback is sent over the new session.  Some
> 
>       servers will do this very quickly, some might take longer.
> 
> -    FLAGS: destroy_session ganesha
> 
> +    FLAGS: destroy_session
> 
>      CODE: DSESS9003
> 
>      """
> 
>      recall = threading.Event()
> 
> -- 
> 
> 2.5.5
> 
>  
> 
>  
> 
>  
> 
