Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35170 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdE3S6O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 May 2017 14:58:14 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: GSS sequence number window
Date: Tue, 30 May 2017 14:58:00 -0400
Message-Id: <63736845-2BD3-4EE1-AC12-0BD21A9ABEF2@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Bruce!

While testing with sec=krb5 and sec=krb5i, I noticed a lot of
spurious connection loss, especially when I wanted to run a
CPU-intensive workload on my NFS server at the same time I
was testing.

I added a pr_err() in gss_check_seq_num, and ran a fio job
on a vers=3,sec=sys,proto=tcp mount (server is exporting a
tmpfs). On the server, I rebuilt a kernel source tree cscope
database at the same time.

May 29 17:53:13 klimt kernel: gss_check_seq_num: seq_num = 250098, sd_max = 250291, GSS_SEQ_WIN = 128
May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 937816, sd_max = 938171, GSS_SEQ_WIN = 128
May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 938544, sd_max = 938727, GSS_SEQ_WIN = 128
May 29 17:53:33 klimt kernel: gss_check_seq_num: seq_num = 938543, sd_max = 938727, GSS_SEQ_WIN = 128
May 29 17:53:34 klimt kernel: gss_check_seq_num: seq_num = 939344, sd_max = 939549, GSS_SEQ_WIN = 128
May 29 17:53:35 klimt kernel: gss_check_seq_num: seq_num = 965007, sd_max = 965176, GSS_SEQ_WIN = 128
May 29 17:54:01 klimt kernel: gss_check_seq_num: seq_num = 1799710, sd_max = 1799982, GSS_SEQ_WIN = 128
May 29 17:54:02 klimt kernel: gss_check_seq_num: seq_num = 1831165, sd_max = 1831353, GSS_SEQ_WIN = 128
May 29 17:54:04 klimt kernel: gss_check_seq_num: seq_num = 1883583, sd_max = 1883761, GSS_SEQ_WIN = 128
May 29 17:54:07 klimt kernel: gss_check_seq_num: seq_num = 1959316, sd_max = 1959447, GSS_SEQ_WIN = 128

RFC 2203 suggests there's no risk to using a large window.
My first thought was to make the sequence window larger
(say 2048) but I've seen stragglers outside even that large
a window.

Any thoughts about why there are these sequence number
outliers?


--
Chuck Lever



