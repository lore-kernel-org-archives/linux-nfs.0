Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:33687 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752428AbdFTWqN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jun 2017 18:46:13 -0400
Received: by mail-qt0-f181.google.com with SMTP id u12so145015008qth.0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Jun 2017 15:46:13 -0700 (PDT)
MIME-Version: 1.0
From: Manjunath Patil <mbpatil.linux@gmail.com>
Date: Tue, 20 Jun 2017 15:46:12 -0700
Message-ID: <CANnNPBbyTcx3GBOV1QAs3uq=aGwm_PP0-WRpsOUSFEJWdS6fTQ@mail.gmail.com>
Subject: How to get per export statistics on nfs server
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am looking for a way on nfs server know that the exported directory is in use.
Meaning, not only just mounted, but actually some activity is happening with it.

Is there a command I can use on Linux system to know this?

-Thanks in advance,
Manjunath
