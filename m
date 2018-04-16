Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:39595 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754377AbeDPI4Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2018 04:56:25 -0400
Received: by mail-wr0-f179.google.com with SMTP id q6so11571646wrd.6
        for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2018 01:56:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAABTemQXTxKgqxywjeZ_ORoNqi5pz_HAk9qn=Tu0wnsru0bcFw@mail.gmail.com>
References: <CAABTemQXTxKgqxywjeZ_ORoNqi5pz_HAk9qn=Tu0wnsru0bcFw@mail.gmail.com>
From: "Antonio M." <quactinoids@gmail.com>
Date: Mon, 16 Apr 2018 14:26:23 +0530
Message-ID: <CAABTemTxemq+34ZAvnf8ABuKF2ev9Nz82H+SorHAHGLL3csCNg@mail.gmail.com>
Subject: Fwd: Questions on pynfs:st_lock.py:testLongPoll
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

It looks like "testLongPoll" in st_lock.py is trying to test whether
lock is not prematurely reaped out before lease expires.

However, I don't understand that the following part of the code where
lockowner3 is trying to grab a lock is also part of the same Client
and owns the same ClientID.

So, after perforing that operation, lease on client will be renewed.
And thus, lease will never expire. Only when the loop completes, LOCK
will be unlocked by the first owner.

Also, the test does not consider that if NFS server is implementing
delayed return of DENIAL for conflicting locks.

Does this test assume certain NFS server implementation ? Also, what
if the lease is anyway going to be renewed for failed operation as
well for same client id ?

    # Poll for lock
    while timeleft:
        time.sleep(1)
        if badpoll:
            # Third owner tries to butt in and steal lock
            res3 = c.lock_file("owner3", fh3, stateid3,
                               type=WRITEW_LT, lockowner="lockowner3_LOCK22")
            if res3.status == NFS4_OK:
                t.pass_warn("Locking is not fair")
            check(res3, NFS4ERR_DENIED,
