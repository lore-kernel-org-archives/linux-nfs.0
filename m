Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:37096 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732457AbeHBRFy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Aug 2018 13:05:54 -0400
Received: by mail-ua0-f179.google.com with SMTP id y10-v6so1703823uao.4
        for <linux-nfs@vger.kernel.org>; Thu, 02 Aug 2018 08:14:17 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 2 Aug 2018 11:14:15 -0400
Message-ID: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
Subject: noresvport and port re-use
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

There is no documentation of this behavior but when "noresvport" is
specified, the client will not try to re-use the port upon connection
re-establishement. Is this an oversight or a desired behavior (ie.,
client doesn't need to be conservative and re-use ports)?

Thank you.
