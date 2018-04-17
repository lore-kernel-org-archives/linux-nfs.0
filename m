Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:45089 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751857AbeDQOCo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 10:02:44 -0400
Received: by mail-wr0-f177.google.com with SMTP id u11so35856737wri.12
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2018 07:02:43 -0700 (PDT)
MIME-Version: 1.0
From: "Antonio M." <quactinoids@gmail.com>
Date: Tue, 17 Apr 2018 19:32:42 +0530
Message-ID: <CAABTemTHvp+2rthSZNPgZBzfVvumy53bLuKS7wLEcuFopUpVig@mail.gmail.com>
Subject: pynfs blocking lock test
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

It looks like "testLongPoll" in st_lock.py is trying to test whether
lock is not granted to others before client lease expires.

However, I don't understand that the following part of the code where
lockowner3 is trying to grab a lock is also part of the same Client
and sends LOCK with the same ClientID.
...
        if badpoll:
            # Third owner tries to butt in and steal lock
            res3 = c.lock_file("owner3", fh3, stateid3,
                               type=WRITEW_LT, lockowner="lockowner3_LOCK22")
...

So, after performing the LOCK operation (even though it was denied),
lease on client will be renewed.
And thus, lease will never expire. Only when the loop completes, LOCK
will be unlocked by the first owner.

Also, the test does not consider that if NFS server is implementing
delayed return of DENIAL for conflicting locks.

Does this test assume certain NFS server implementation ? Also, what
if the lease is anyway going to be renewed for failed operation since client id
would be matching and that is good enough to renew lease.
