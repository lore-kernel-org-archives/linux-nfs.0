Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:43526 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751140AbdJOTGw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Oct 2017 15:06:52 -0400
Received: by mail-qk0-f178.google.com with SMTP id w134so10456630qkb.0
        for <linux-nfs@vger.kernel.org>; Sun, 15 Oct 2017 12:06:52 -0700 (PDT)
MIME-Version: 1.0
From: Sverd Johnsen <sverd.johnsen@googlemail.com>
Date: Sun, 15 Oct 2017 21:06:51 +0200
Message-ID: <CAGmahrTrXKdc2tDN4eByn+-WBrp1cz4aU6QWE5k2rNZSi3PKmw@mail.gmail.com>
Subject: rpc.gssd vs 32bit userland on aarch64
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I noticed that it calls syscall directly in gssd_proc.c. This fails
here as setgroups, setresuid and setresgid don't seem to work.
