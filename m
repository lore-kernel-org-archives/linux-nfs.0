Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60514 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753567AbdK3RED (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 12:04:03 -0500
Date: Thu, 30 Nov 2017 12:04:03 -0500
To: "Lu, Xinyu" <luxy.fnst@cn.fujitsu.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pynfs nfs4.0 server st_write: fix the amount of data
 sent in the testLargeData
Message-ID: <20171130170403.GD3923@fieldses.org>
References: <2af20316-5ce4-354e-8768-4462398dc36f@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2af20316-5ce4-354e-8768-4462398dc36f@cn.fujitsu.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, this test is weird, I'm not sure what to do with it.

If we want the writet to succeed then pynfs should first query the
server for the maximum write size and use that--not every server will
have 1M as the maximum.

Maybe the intent was just to see if the server handles a too-large value
gracefullly.  But in that case it should probably use a much larger
write (to ensure that it will be too much for any server), and be
modified to expect the server to fail.

--b.

On Thu, Nov 30, 2017 at 08:13:14AM +0000, Lu, Xinyu wrote:
>  nfs4.0 server st_write: fix the amount of data sent in the testLargeData
>     
>     The maximum amount of data could be writen is NFSSVC_MAXBLKSIZE. The value of NFSSVC_MAXB
> LKSIZE defined in the kernel is RPCSVC_MAXPLAYLOAD. If the value written exceeds NFSSVC_MAXBL
> KSIZE, the value is fixed as the value of NFSSVC_MAXBLKSIZE. The value of RPCSVC_MAXPAYLOAD i
> s 1*1024*1024u and "abcdefghijklmnopq"*0x10000 exceeds it. So the previous test is bound to f
> ail and is meaningless.
> 
>     Signed-off-by: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
> 
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index 710452e..a7dae03 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -130,7 +130,7 @@ def testLargeData(t, env):
>      c = env.c1
>      c.init_connection()
>      fh, stateid = c.create_confirm(t.code)
> -    data = "abcdefghijklmnopq" * 0x10000
> +    data = "a" * 1024 * 1024
>      # Write the data
>      pos = 0
>      while pos < len(data):
> 
> 

> From 6adc3da0ab17eb7e52b47805e6999d65b043fa7f Mon Sep 17 00:00:00 2001
> From: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
> Date: Thu, 30 Nov 2017 13:24:15 +0800
> Subject: [PATCH] nfs4.0 server st_write: fix the amount of data sent in the
>  testLargeData
> 
> The maximum amount of data could be writen is NFSSVC_MAXBLKSIZE. The value of NFSSVC_MAXBLKSIZE defined in the kernel is RPCSVC_MAXPLAYLOAD. If the value written exceeds NFSSVC_MAXBLKSIZE, the value is fixed as the value of NFSSVC_MAXBLKSIZE. The value of RPCSVC_MAXPAYLOAD is 1*1024*1024u and "abcdefghijklmnopq"*0x10000 exceeds it. So the previous test is bound to fail and is meaningless.
> 
> Signed-off-by: Lu Xinyu <luxy.fnst@cn.fujitsu.com>
> ---
>  nfs4.0/servertests/st_write.py | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index 710452e..a7dae03 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -130,7 +130,7 @@ def testLargeData(t, env):
>      c = env.c1
>      c.init_connection()
>      fh, stateid = c.create_confirm(t.code)
> -    data = "abcdefghijklmnopq" * 0x10000
> +    data = "a" * 1024 * 1024
>      # Write the data
>      pos = 0
>      while pos < len(data):
> -- 
> 2.13.3
> 

