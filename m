Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f52.google.com ([209.85.222.52]:35262 "EHLO
        mail-ua1-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726941AbeJDBU7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2018 21:20:59 -0400
Received: by mail-ua1-f52.google.com with SMTP id m18so2286354uaq.2
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2018 11:31:26 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 3 Oct 2018 14:31:14 -0400
Message-ID: <CAN-5tyH_+OZJ+eUGvqvo+-EuG1OdaoFYERNKi=k=CDxpOFVoCQ@mail.gmail.com>
Subject: NFS/TCP timeouts
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

Is it true that NFS mount option "timeo" has nothing to do with the
socket's setting of the user-specified timeout TCP_USER_TIMEOUT.
Instead, when creating a TCP socket NFS uses either default/hard coded
value of 60s for v3 or for v4.x it's lease based. Is there no value is
having an adjustable TCP timeout value?

Thank you.
