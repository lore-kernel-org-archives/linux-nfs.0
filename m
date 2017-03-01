Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33627 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751081AbdCAUM6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Mar 2017 15:12:58 -0500
Received: by mail-qk0-f182.google.com with SMTP id n127so89367842qkf.0
        for <linux-nfs@vger.kernel.org>; Wed, 01 Mar 2017 12:11:39 -0800 (PST)
MIME-Version: 1.0
From: Chris Wheeler <grintor@gmail.com>
Date: Wed, 1 Mar 2017 15:03:30 -0500
Message-ID: <CANqgWRN=GPjpz0OboaQ3MWccJuBKY55mXZFC-r_pPWbvMjj63w@mail.gmail.com>
Subject: mount NFS 4.1 with session trunking
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

I am trying to find some sort of documentation of how to mount a NFS
4.1 share using session trunking under Linux. All I can find is
information of how to do it under VMware ESXI, (in VMware, you simply
specify multiple IP addresses for your NAS).

The linux mount man page and nfs man page don't document how to
specify the IPs you want to use for session trunking, or how to enable
it.

Can anyone help?

Thank you,
Chris
