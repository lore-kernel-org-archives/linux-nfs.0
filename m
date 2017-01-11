Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:34476 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761349AbdAKO1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 09:27:39 -0500
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 686252806DD
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 15:27:37 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
        by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 5B64513E8C
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 15:27:37 +0100 (MET)
Date: Wed, 11 Jan 2017 15:27:36 +0100 (CET)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Message-ID: <269480200.33048710.1484144856797.JavaMail.zimbra@desy.de>
In-Reply-To: <20170110120229.23413-2-tigran.mkrtchyan@desy.de>
References: <20170110120229.23413-1-tigran.mkrtchyan@desy.de> <20170110120229.23413-2-tigran.mkrtchyan@desy.de>
Subject: Re: [PATCH 2/2] st_write: test server behavior on WRITE with
 offset+len > maxfilesize
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce & Co.

Please ignore this patches, as they break some other test.
I will resubmit new test of patches.

Tigran.

----- Original Message -----
> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> To: bfields@fieldses.org
> Cc: linux-nfs@vger.kernel.org, "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> Sent: Tuesday, January 10, 2017 1:02:29 PM
> Subject: [PATCH 2/2] st_write: test server behavior on WRITE with offset+len > maxfilesize

> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
> nfs4.0/servertests/st_write.py | 17 +++++++++++++++++
> 1 file changed, 17 insertions(+)
> 
> diff --git a/nfs4.0/servertests/st_write.py b/nfs4.0/servertests/st_write.py
> index 710452e..3781210 100644
> --- a/nfs4.0/servertests/st_write.py
> +++ b/nfs4.0/servertests/st_write.py
> @@ -499,3 +499,20 @@ def testStolenStateid(t, env):
>     res = c.write_file(fh, _text, stateid=stateid)
>     c.security=security
>     check(res, [NFS4ERR_ACCESS, NFS4ERR_PERM], "WRITE with stolen stateid")
> +
> +def testWriteOffsetOverflow(t, env):
> +    """WRITE with offset + length bigger than UINT64_MAX
> +
> +    FLAGS: write all
> +    DEPEND: MKFILE
> +    CODE: WRT20
> +    """
> +    c = env.c1
> +    c.init_connection()
> +
> +    max_filesize = c.do_getattr(FATTR4_MAXFILESIZE)
> +    fh, stateid = c.create_confirm(t.code)
> +    data = "abcde"
> +
> +    res = c.write_file(fh, data, max_filesize - 1, stateid)
> +    check(res, NFS4ERR_INVAL, msg="WRITE with offset + length bigger than
> UINT64_MAX")
> --
> 2.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
