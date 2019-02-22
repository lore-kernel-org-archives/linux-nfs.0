Return-Path: <SRS0=ibFv=Q5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3686C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6965520675
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Feb 2019 21:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mhilJ3ts"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725900AbfBVV6z (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Feb 2019 16:58:55 -0500
Received: from mail-it1-f170.google.com ([209.85.166.170]:36147 "EHLO
        mail-it1-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725832AbfBVV6z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Feb 2019 16:58:55 -0500
Received: by mail-it1-f170.google.com with SMTP id h6so5479665itl.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Feb 2019 13:58:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=uqwPSTSTyg2Du3TNfDNJchVaN8gk0hwPxrInhdsT1eQ=;
        b=mhilJ3tsKzeuVKHiqVBz3qidIbJE0/BsZx320Vj+adegQiR35ANWt5DVwpj2S4o8WS
         MxIeThQZnqz5FJ9UbRjvi56D+4RUblksqj6zE/ZsNfvMqxPp0a52pqqx7x9Lj+ONbQ18
         vgBXM2A5+xvoymqu6NW0pKWDjwpUANTwJ089xk4Km4KAL3geqx/aPQwEeZZEYO/sjCYZ
         F5PqD62ak2Zk1HHyC/SQMgJBrpDpc50TBIwP7YGET3rrFEPzln5ZT3xdxPP18p4BpYwD
         /c1oPKFaJuCbXRb/eSJjo7hAAaZrk28tV0R7WL1zdxYrE/1CIw6veVwWdVYwx6tWVcIG
         F5+A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:from:to:cc:subject:date:message-id
         :mime-version:content-transfer-encoding;
        bh=uqwPSTSTyg2Du3TNfDNJchVaN8gk0hwPxrInhdsT1eQ=;
        b=SU+Xqt9A/N5d5+OZhMbKNKSDXH9Xtgdu4fe8ibfiinoqxy0HUZh8yKhR5YTAM1cCNr
         GvLzyFmV+/bUxnJdiv1Vpi8VNNxQSGmDqb8RZSYX7E/i3f53rHVeAO2Ec4NaGK42IaNu
         00hHr05XWUBBm9La8K4LfyN1omm6wpCtfNKGVOYgdELuLtlCwoquBVKBLBq+NCadefTP
         xHYDunTq5gwDBR1SqkkK92Jr9MxGpu4B6TZKEv8jrtb0z9dvfy7kRDj/3VpqYeh1vLFc
         mRWT2jYHmSJhCseqt8WfG1VZwU+WyIQO7SviW+4vcnFutoFwL7VwnE5s0RjQut4ckeuX
         XsGw==
X-Gm-Message-State: AHQUAubJI+UcB1muysPaMbsMBuIO++LkUqXb5SPb4CDicyYNg2QApnIV
        CSt2CX5oUAgdQCDU/dHURdEkOjMxL/Q=
X-Google-Smtp-Source: AHgI3IZfwISfNQHv6j15LhKIUVQvnV2S1qZaE4S/zRbaUVtGOJ1Wr7knX0NVMgQItOrYKjacZYW3rg==
X-Received: by 2002:a05:660c:fcd:: with SMTP id m13mr3991666itn.77.1550872733674;
        Fri, 22 Feb 2019 13:58:53 -0800 (PST)
Received: from gouda.nowheycreamery.com.nowheycreamery.com (d28-23-121-75.dim.wideopenwest.com. [23.28.75.121])
        by smtp.gmail.com with ESMTPSA id t74sm1532459itt.29.2019.02.22.13.58.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 13:58:52 -0800 (PST)
From:   Anna Schumaker <schumaker.anna@gmail.com>
X-Google-Original-From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFSD: Add support for the v4.2 READ_PLUS operation
Date:   Fri, 22 Feb 2019 16:58:48 -0500
Message-Id: <20190222215850.20508-1-Anna.Schumaker@Netapp.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These patches add server support for the READ_PLUS operation.  This
operation is meant to improve file reading performance when working with
sparse files, but there are some issues around the use of vfs_llseek() to
identify hole and data segments when encoding the reply.  I've done a
bunch of testing on virtual machines, and I found that READ_PLUS
performs best if:

  1) The file being read is not yet in the server's page cache.
  2) The read request begins with a hole segment. And
  3) The server only performs one llseek() call during encoding

I've added a "noreadplus" mount option on the client side to allow users
to disable the new operation if it becomes a problem, similar to the
"nordirplus" mount option that we already have.

Here are the results of my performance tests, separated by underlying
filesystem and if the file is already in the cache or not.  The NFS v4.2
column is for the standard READ operation, and v4.2+ is with READ_PLUS.
In addition to the 100% data and 100% hole cases, I also test with files
that alternate between data and hole chunks.  I tested with two files
for each chunk size, one beginning with a data segment and one beginning
with a hole.  I used the `vmtouch` utility to load and clear the file
from the server's cache, and I used the following `dd` command on the
client for reading back the file:

  $ dd if=$src of=/dev/null bs=$rsize_from_mount 2>&1


     xfs (uncached)     |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  3.228s    3.361s    3.679s    3.382s    3.483s
   Whole File (hole)    |  1.276s    1.086s    1.143s    1.066s    0.805s
   Sparse  4K (data)    |  3.473s    3.953s    3.740s    3.535s    3.515s
   Sparse  4K (hole)    |  3.373s    3.192s    3.120s    3.113s    2.709s
   Sparse  8K (data)    |  3.782s    3.527s    3.589s    3.476s    3.494s
   Sparse  8K (hole)    |  3.161s    3.328s    2.974s    2.889s    2.863s
   Sparse 16K (data)    |  3.804s    3.945s    3.885s    3.507s    3.569s
   Sparse 16K (hole)    |  2.961s    3.124s    3.413s    3.136s    2.712s
   Sparse 32K (data)    |  2.891s    3.632s    3.833s    3.643s    3.485s
   Sparse 32K (hole)    |  2.592s    2.216s    2.545s    2.665s    2.829s

      xfs (cached)      |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  0.939s    0.943s    0.939s    0.942s    1.153s
   Whole File (hole)    |  0.982s    1.007s    0.991s    0.946s    0.826s
   Sparse  4K (data)    |  0.980s    0.999s    0.961s    0.996s    1.166s
   Sparse  4K (hole)    |  1.001s    0.972s    0.997s    1.001s    1.201s
   Sparse  8K (data)    |  1.272s    1.053s    0.999s    0.974s    1.200s
   Sparse  8K (hole)    |  0.965s    1.004s    1.036s    1.006s    1.248s
   Sparse 16K (data)    |  0.995s    0.993s    1.035s    1.054s    1.210s
   Sparse 16K (hole)    |  0.966s    0.982s    1.091s    1.038s    1.214s
   Sparse 32K (data)    |  1.054s    0.968s    1.045s    0.990s    1.203s
   Sparse 32K (hole)    |  1.019s    0.960s    1.001s    0.983s    1.254s

    ext4 (uncached)     |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  6.089s    6.104s    6.489s    6.342s    6.137s
   Whole File (hole)    |  2.603s    2.258s    2.226s    2.315s    1.715s
   Sparse  4K (data)    |  7.063s    7.372s    7.064s    7.149s    7.459s
   Sparse  4K (hole)    |  7.231s    6.709s    6.495s    6.880s    6.138s
   Sparse  8K (data)    |  6.576s    6.938s    6.386s    6.086s    6.154s
   Sparse  8K (hole)    |  5.903s    6.089s    5.555s    5.578s    5.442s
   Sparse 16K (data)    |  6.556s    6.257s    6.135s    5.588s    5.856s
   Sparse 16K (hole)    |  5.504s    5.290s    5.545s    5.195s    4.983s
   Sparse 32K (data)    |  5.047s    5.490s    5.734s    5.578s    5.378s
   Sparse 32K (hole)    |  4.232s    3.860s    4.299s    4.466s    4.633s

     ext4 (cached)      |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  1.873s    1.881s    1.869s    1.890s    2.344s
   Whole File (hole)    |  1.929s    2.009s    1.963s    1.917s    1.554s
   Sparse  4K (data)    |  1.961s    1.974s    1.957s    1.986s    2.408s
   Sparse  4K (hole)    |  2.056s    2.025s    1.977s    1.988s    2.458s
   Sparse  8K (data)    |  2.297s    2.038s    2.008s    1.954s    2.437s
   Sparse  8K (hole)    |  1.939s    2.011s    2.024s    2.015s    2.509s
   Sparse 16K (data)    |  1.907s    1.973s    2.053s    2.070s    2.411s
   Sparse 16K (hole)    |  1.940s    1.964s    2.075s    1.996s    2.422s
   Sparse 32K (data)    |  2.045s    1.921s    2.021s    2.013s    2.388s
   Sparse 32K (hole)    |  1.984s    1.944s    1.997s    1.974s    2.398s

    btrfs (uncached)    |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  9.369s    9.438s    9.837s    9.840s   11.790s
   Whole File (hole)    |  4.052s    3.390s    3.380s    3.619s    2.519s
   Sparse  4K (data)    |  9.738s   10.110s    9.774s    9.819s   12.471s
   Sparse  4K (hole)    |  9.907s    9.504s    9.241s    9.610s    9.054s
   Sparse  8K (data)    |  9.132s    9.453s    8.954s    8.660s   10.555s
   Sparse  8K (hole)    |  8.290s    8.489s    8.305s    8.332s    7.850s
   Sparse 16K (data)    |  8.742s    8.507s    8.667s    8.002s    9.940s
   Sparse 16K (hole)    |  7.635s    7.604s    7.967s    7.558s    7.062s
   Sparse 32K (data)    |  7.279s    7.670s    8.006s    7.705s    9.219s
   Sparse 32K (hole)    |  6.200s    5.713s    6.268s    6.464s    6.486s

     btrfs (cached)     |  NFS v3  NFS v4.0  NFS v4.1  NFS v4.2  NFS v4.2+
------------------------+-------------------------------------------------
   Whole File (data)    |  2.770s    2.814s    2.841s    2.854s    3.492s
   Whole File (hole)    |  2.871s    2.970s    3.001s    2.929s    2.372s
   Sparse  4K (data)    |  2.945s    2.905s    2.930s    2.951s    3.663s
   Sparse  4K (hole)    |  3.032s    3.057s    2.962s    3.050s    3.705s
   Sparse  8K (data)    |  3.277s    3.069s    3.127s    3.034s    3.652s
   Sparse  8K (hole)    |  2.866s    2.959s    3.078s    2.989s    3.762s
   Sparse 16K (data)    |  2.916s    2.923s    3.060s    3.081s    3.631s
   Sparse 16K (hole)    |  2.948s    2.969s    3.108s    2.990s    3.623s
   Sparse 32K (data)    |  3.044s    2.881s    3.052s    2.962s    3.585s
   Sparse 32K (hole)    |  2.954s    2.957s    3.018s    2.951s    3.639s


I also have performance numbers for if we encode every hole and data
segment but I figured this email was long enough already. I'm happy to
share it if requested!

Thoughts?
Anna

-------------------------------------------------------------------------

Anna Schumaker (2):
  NFSD: nfsd4_encode_read{v}() should encode eof and maxcount
  NFSD: Add basic READ_PLUS support

 fs/nfsd/nfs4proc.c |  16 ++++
 fs/nfsd/nfs4xdr.c  | 180 ++++++++++++++++++++++++++++++++++-----------
 2 files changed, 153 insertions(+), 43 deletions(-)

-- 
2.20.1

