Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35537 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753975AbcIVQTy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Sep 2016 12:19:54 -0400
Received: by mail-io0-f176.google.com with SMTP id m186so90857724ioa.2
        for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2016 09:19:53 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 22 Sep 2016 12:19:52 -0400
Message-ID: <CAN-5tyGvm9ZLcL2AGGzALCtJ90fEc1SHeod6V4ZpSf8WSHUJtQ@mail.gmail.com>
Subject: sunrpc's tcp_max_slot_table_entries
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

There used to be a configurable parameter in sunrpc called
"tcp_max_slot_table_entries" that no longer works (meaning that rpc
slot table is always created with 65536 slots regardless of what the
value is set to). Is the change intentional or a bug? A look thru git
log of xprtsock.c didn't reveal an entry stating of such change.

Thank you.
