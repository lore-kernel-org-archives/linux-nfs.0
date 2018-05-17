Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:41154 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbeEQUng (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2018 16:43:36 -0400
Received: by mail-vk0-f50.google.com with SMTP id 131-v6so3534060vkf.8
        for <linux-nfs@vger.kernel.org>; Thu, 17 May 2018 13:43:36 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 17 May 2018 16:43:34 -0400
Message-ID: <CAN-5tyH2OVzr5TTN_sCrKxEiXaDiPzh=8zykR__jq=k2ve5Vaw@mail.gmail.com>
Subject: question: re-try of operations in PNFS
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Is there a reason why an rpc connection to the DS is set to timeout
requests instead of waiting until the reply from the server ? Requests
to DS timeout in 10sec and are resent to MDS.

Thank you.
