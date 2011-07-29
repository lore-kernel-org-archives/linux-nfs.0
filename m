Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:47608 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab1G2Rpu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jul 2011 13:45:50 -0400
Received: by vxh35 with SMTP id 35so2860074vxh.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Jul 2011 10:45:49 -0700 (PDT)
In-Reply-To: <20110729155136.GB28306@infradead.org>
References: <1311874276-1386-1-git-send-email-rees@umich.edu> <20110729155136.GB28306@infradead.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Sat, 30 Jul 2011 01:45:29 +0800
Message-ID: <CA+a=Yy78jFNm+fqmX9FeK5MivT4A3homrV2=ZQLHgzusZZ0x+Q@mail.gmail.com>
Subject: Re: [PATCH v4 00/27] add block layout driver to pnfs client
To: Christoph Hellwig <hch@infradead.org>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Christoph,

On Fri, Jul 29, 2011 at 11:51 PM, Christoph Hellwig <hch@infradead.org> wrote:
> How well is the I/O code tested?  It's a full reimplementation of
> code full of nasty traps.  Did you run xfstests over it?  It supports
> nfs, so pointing it to a pnfs share should probably just work.
We have been testing the code with cthon04 for some time and all cased
are passed since the earliest version.

And I just had a try with xfstests. It seems it does not support NFSv4
right now. I had to modify common.rc to make "./check -nfs" runable.
Otherwise it failed with:
common.rc: Error: $TEST_DEV (10.244.82.74:/s4fs1/) is not a MOUNTED
nfs filesystem
I tried mounting TEST_DIR both w/ and w/o pnfs. The same errors.

After fixing common.rc, "./check -nfs" can run but failed and stopped
at case 088. Both pnfs block and NFSv4 failed at the same case. Did
anyone run xfstests over NFSv4 before? I'm wondering whether it is a
regression or if case 088 is valid for NFSv4.
088      - output mismatch (see 088.out.bad)
--- 088.out     2011-07-29 07:33:58.180218573 -0400
+++ 088.out.bad 2011-07-29 08:50:55.242319901 -0400
@@ -1,9 +1,2 @@
 QA output created by 088
-access(TEST_DIR/t_access, 0) returns 0
-access(TEST_DIR/t_access, R_OK) returns 0
-access(TEST_DIR/t_access, W_OK) returns 0
-access(TEST_DIR/t_access, X_OK) returns -1
-access(TEST_DIR/t_access, R_OK | W_OK) returns 0
-access(TEST_DIR/t_access, R_OK | X_OK) returns -1
-access(TEST_DIR/t_access, W_OK | X_OK) returns -1
-access(TEST_DIR/t_access, R_OK | W_OK | X_OK) returns -1
+fchown: Invalid argument

-- 
Thanks,
Tao
