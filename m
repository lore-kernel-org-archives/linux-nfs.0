Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:42389 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934046AbaKNQM2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 11:12:28 -0500
Received: by mail-ie0-f174.google.com with SMTP id x19so18266635ier.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2014 08:12:28 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 14 Nov 2014 11:12:28 -0500
Message-ID: <CAN-5tyFYZ2s4gV-ahQ4H4kZuqjez087sSpSuUeJ4UtDdW8MNag@mail.gmail.com>
Subject: calls to rpc_peeraddr2str()
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Should all calls to rpc_peeraddr2str() be protected with
rcu_read_lock(). callback_proc.c makes calls to rpc_peeraddr2str()
without acquiring such lock. Can somebody comment if this is a bug?

Thank you.
