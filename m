Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62353 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752228Ab0H0XI0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Aug 2010 19:08:26 -0400
Received: by wwb28 with SMTP id 28so4061691wwb.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Aug 2010 16:08:25 -0700 (PDT)
Date: Fri, 27 Aug 2010 18:08:25 -0500
Message-ID: <AANLkTimog6uTdsxzFeA0YY+HK6gtcwEGXaFDJs+Aorm0@mail.gmail.com>
Subject: 30 time speed difference between using NFS and without using NFS
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I use the following command to search for some directory.

find -L some_dir -type d -name some_name

If I'm on the machine that has some_dir locally, the run time is
real	0m0.199s
user	0m0.048s
sys	0m0.140s

If I'm on another machine that sees the same directory by NFS (NFS3).
the run time is
real	0m6.509s
user	0m0.090s
sys	0m1.380s

There are 30 time speed difference. Is this normal? Is there any NFS
parameter that I should tune to make the latter faster?

-- 
Regards,
Peng
