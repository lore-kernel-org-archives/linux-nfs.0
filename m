Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:36186 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdAXTGj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:06:39 -0500
Received: by mail-io0-f175.google.com with SMTP id j13so142916334iod.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 11:06:39 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 24 Jan 2017 14:06:38 -0500
Message-ID: <CAN-5tyF+Uth87mnmWC2UaRU134whqNG8gEyNHBR_hOu9OYSZuw@mail.gmail.com>
Subject: handling error on RECLAIM_COMPLETE
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Is there a reason that nfs4_proc_reclaim_complete() isn't  wrapped
with a do while() to handle errors?

Thanks.
