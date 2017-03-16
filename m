Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38432 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752578AbdCPSFu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Mar 2017 14:05:50 -0400
Received: by mail-it0-f45.google.com with SMTP id m27so54338096iti.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Mar 2017 11:05:49 -0700 (PDT)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 16 Mar 2017 14:05:43 -0400
Message-ID: <CAN-5tyH433qTV9EY5MQpDhRhgekUv7e=R1H7N_Q_46cAwPO=eg@mail.gmail.com>
Subject: question about open_owner sequencing
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I have a question about recovery from the BAD_SEQID and what should happen.

I have the following application that does:

1. open(file1)
2. open(file2)
3. close(file1)
4. open(file3)
5. lock(file2)

If CLOSE gets BAD_SEQID (for whatever reason), I see that LOCK later
fails with BAD_SEQID as well.

step1 OPEN creates open_owner1 seq 0
step2 OPEN uses open_owner1 seq1
step3 CLOSE uses open_owner1 seq2 gets BAD_SEQID
step4 OPEN sends new open_owner2 seq2 and it triggers OPEN_CONFIRM with seq3
step5 sends LOCK with seq4 and open stateid from the reply in step 2.

LOCK gets BAD_SEQID.

Question: is client sending something incorrect? is server not
correct? I tested against two different servers (Linux and NetApp) and
both reply the same way so I'm leaning towards "no". But I don't see
why "seq4" is not a valid sequence given that the open_owner/sequence
was just confirmed.

Thanks.
