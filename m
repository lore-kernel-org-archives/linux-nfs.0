Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:41169 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032437AbeBOCKX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Feb 2018 21:10:23 -0500
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 794CAAC00A3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Feb 2018 11:10:16 +0900 (JST)
Subject: Re: Questions about pynfs:testLargeData-WRT5
To: <bfields@redhat.com>
CC: <trondmy@primarydata.com>, <luxy.fnst@cn.fujitsu.com>,
        <linux-nfs@vger.kernel.org>
References: <20180209183112.GC30030@parsley.fieldses.org>
 <6c3159af-17c5-5556-d416-574968bb5e14@cn.fujitsu.com>
 <738139ab-6a55-4c93-008d-56a2332774c9@jp.fujitsu.com>
 <20180213161540.GA26270@parsley.fieldses.org>
 <20180214154909.GA32456@parsley.fieldses.org>
From: Seiichi Ikarashi <s.ikarashi@jp.fujitsu.com>
Message-ID: <225b853a-d388-f281-0902-d34f998210bf@jp.fujitsu.com>
Date: Thu, 15 Feb 2018 11:08:51 +0900
MIME-Version: 1.0
In-Reply-To: <20180214154909.GA32456@parsley.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2018-02-15 00:49, J. Bruce Fields wrote:
> On Tue, Feb 13, 2018 at 11:15:40AM -0500, J. Bruce Fields wrote:
>> WRT5 is wrong in any case, I'll fix it.
> 
> How about this?
> 
> --b.
> 
> commit 30f1fff66da3
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Feb 13 16:30:27 2018 -0500
> 
>     4.0 server tests: replace WRT5 by better tests
>     
>     This test is sending a write that (at least in the knfsd case) is larger
>     than the server's maximum write size, and expecting it to succeed.
>     That's weird.
>     
>     Remove WRT5 and replace it by two tests.  Both first query the maximum

Really good to split it into WRT5a and WRT5b!

>     write size.  One does a large (but not too large) write and checks that
>     the data was written correctly.  The other does a too-large write and
>     expects nothing.  (A wide variety of server behavior would be in spec;
>     we do this just in case a buggy server might crash.)
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index 710452efa11d..004562d2f52b 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -120,17 +120,22 @@ def testNoData(t, env):
>      if compareTimes(time_prior,time_after) != 0:
>          t.fail("WRITE with no data affected time_modify")
>  
> +#WRT5 permanently retired
> +
>  def testLargeData(t, env):

How about the name "testMaximumData()" or something?
It's not just "Large".

> -    """WRITE with a large amount of data
> +    """WRITE with the maximum size, READ it back and compare
>  
>      FLAGS: write read all
>      DEPEND: MKFILE
> -    CODE: WRT5
> +    CODE: WRT5a
>      """
>      c = env.c1
>      c.init_connection()
> +    maxread, maxwrite = _get_iosize(t, c, c.homedir)
> +    maxio = min(maxread, maxwrite)
>      fh, stateid = c.create_confirm(t.code)
> -    data = "abcdefghijklmnopq" * 0x10000
> +    pattern="abcdefghijklmnop"
> +    data = pattern * (maxio / len(pattern)) + "q" * (maxio % len(pattern))
>      # Write the data
>      pos = 0
>      while pos < len(data):
> @@ -150,6 +155,27 @@ def testLargeData(t, env):
>      if data != newdata:
>          t.fail("READ did not correspond to WRITE with large dataset")
>  
> +def testTooLargeData(t, env):
> +    """WRITE with more than the maximum size

                with 10^6 bytes beyond the maximum size

Regards,
Ikarashi

> +
> +    FLAGS: write read all
> +    DEPEND: MKFILE
> +    CODE: WRT5b
> +    """
> +    c = env.c1
> +    c.init_connection()
> +    maxread, maxwrite = _get_iosize(t, c, c.homedir)
> +    fh, stateid = c.create_confirm(t.code)
> +    data = "a" * (maxwrite + 1000000)
> +    try:
> +        # We don't care much what the server does, this is just a check
> +        # to make sure it doesn't crash.
> +        res = c.write_file(fh, data, 0, stateid)
> +    except IOError:
> +        # Linux knfsd closes the socket when the write is too large.
> +        # That's OK.
> +        pass
> +
>  def testDir(t, env):
>      """WRITE to a dir should return NFS4ERR_ISDIR
>  
> 
> 
> .
> 


