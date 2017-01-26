Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:33409 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753274AbdAZUdT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2017 15:33:19 -0500
Received: by mail-io0-f171.google.com with SMTP id v96so46179878ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jan 2017 12:33:04 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 26 Jan 2017 15:01:54 -0500
Message-ID: <CAN-5tyEo-VS6y1-WVJMDXSzN2vxDtJOSckiYK=HmqLyPvBpWFQ@mail.gmail.com>
Subject: regression from commit 24408f5282
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

There is regression in the upstream code, it leaves dangling DS
mounts. Problem didn't exist in 4.9 and appeared in 4.10.

Simple test is : mount, echo 1 > /mnt/foobar, unmount /mnt. Watch the
DS mount keep going.

The last commit at which the code works is: fe1cf9469d7 "pNFS: Clear
all layout segment state in pnfs_mark_layout_stateaid_invalid".

Applying commit 24408f5282 "pNFS: Fix bugs in _pnfs_return_layout"
introduces the problem.
