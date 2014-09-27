Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:39369 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752738AbaI0PWa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Sep 2014 11:22:30 -0400
Received: by mail-ig0-f175.google.com with SMTP id h18so970448igc.8
        for <linux-nfs@vger.kernel.org>; Sat, 27 Sep 2014 08:22:30 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 27 Sep 2014 11:22:29 -0400
Message-ID: <CAABAsM4zDuzjapXfLUrminwM1FV7iwN+oEzxgzaQ60m93gBBug@mail.gmail.com>
Subject: Could somebody please enlighten me as to what is supposed to happen
 in this situation?
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "nfsv4@ietf.org" <nfsv4@ietf.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The scenario is this:
                                       Server
                                       ======
                                       boot (B1)
Client
======
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)
LOCK(reclaim)
RECLAIM_COMPLETE
                                       (lift GRACE period)
                                       reboot (B2)
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)
                                        reboot (while GRACE period
still being enforced) (B3)
EXCHANGE_ID
CREATE_SESSION
OPEN(reclaim)

What should be the server response to the above OPEN(reclaim) from the
client after reboot (B3)?

Cheers
  Trond
