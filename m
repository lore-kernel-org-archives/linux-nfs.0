Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:41908 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899Ab1HFPwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Aug 2011 11:52:40 -0400
Received: by pzk37 with SMTP id 37so5621454pzk.1
        for <linux-nfs@vger.kernel.org>; Sat, 06 Aug 2011 08:52:40 -0700 (PDT)
From: Peng Tao <bergwolf@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: rees@umich.edu, bhalevy@tonian.com, Trond.Myklebust@netapp.com
Subject: [PATCH-RFC 0/2] pNFS: recoalesce pages when ld read/write fails
Date: Sat,  6 Aug 2011 08:52:12 -0700
Message-Id: <1312645934-4436-1-git-send-email-bergwolf@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Hi,

I start to look at the error handling for ld_read/write_done.
The two patches try to address the error handling for read/write pagelist
failures, via nfs readpage/writepage interface. Please see if this method
is proper. Thanks!

Cheers,
Tao

