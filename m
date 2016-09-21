Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:32914 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932189AbcIUOTk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2016 10:19:40 -0400
Received: by mail-yw0-f180.google.com with SMTP id i129so55296966ywb.0
        for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2016 07:19:39 -0700 (PDT)
MIME-Version: 1.0
From: Mayur Bajaj <mbajaj@maprtech.com>
Date: Wed, 21 Sep 2016 19:49:38 +0530
Message-ID: <CAKqBuofwLwUq0D8D_wnZ+f-ig1gO2QdSTjQ9ykkHb0NMaX3FoA@mail.gmail.com>
Subject: NFS client behaviour with soft mount
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I have a question regarding NFS client behaviour with soft mount. I
have gone through the code but could not figure out. Can someone
please help me.

An application is writing data via NFS client (soft mount, with sync
mount option NOT set). The Application thinks that data written was
successful but that is not the case.
The NFS client will cache all the write request and flush after some
time/threshold. The NFS sever is not responding. NFS client retries
for 3 times (or retrans) and give up as the NFS server is not
responding.

Will this cache pages be pinned in memory for ever or freed up (marked
clean) as the operation has failed?
Will NFS client keep on retrying again?

Thanks in advance
Mayur
