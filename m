Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-la0-f46.google.com ([209.85.215.46]:63754 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944Ab3FWN1x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Jun 2013 09:27:53 -0400
Received: by mail-la0-f46.google.com with SMTP id eg20so9261253lab.19
        for <linux-nfs@vger.kernel.org>; Sun, 23 Jun 2013 06:27:52 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 23 Jun 2013 16:27:52 +0300
Message-ID: <CADnca3voFCr1xbwNcHEq-YCip2ghBrH3Ni2XARfcW6pdLw1K-A@mail.gmail.com>
Subject: LAYOUTGET and NFS4ERR_DELAY: a few questions
From: Nadav Shemer <nadav@tonian.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Background: I'm working on a pnfs-exported filesystem implementation
(using objects-based storage)
In my ->layout_get() implementation, I use mutex_trylock() and return
NFS4ERR_DELAY in the contended case
In a real-world test, I discovered the client always waits 15 seconds
when receiving this error for LAYOUTGET.
This occurs in nfs4_async_handle_error, which always wait for
NFS4_POLL_RETRY_MAX when getting DELAY, GRACE or EKEYEXPIRED

This is in contrast to nfs4_handle_exception, which calls nfs4_delay.
In this path, the wait begins at NFS4_POLL_RETRY_MIN (0.1 seconds) and
increases two-fold each time up to RETRY_MAX.
It is used by many nfs4_proc operations - the caller creates an
nfs4_exception structure, and retries the operation until success (or
permanent error).

when nfs4_async_handle_error is used, OTOH, the RPC task is restarted
in the ->rpc_call_done callback and the sleeping is done with
rpc_delay

nfs4_async_handle_error is used in:
CLOSE, UNLINK, RENAME, READ, WRITE, COMMIT, DELEGRETURN, LOCKU,
LAYOUTGET, LAYOUTRETURN and LAYOUTCOMMIT.
A similar behavior (waiting RETRY_MAX) is also used in
nfs4*_sequence_* functions (in which case it refers to the status of
the SEQUENCE operation itself) and by RECLAIM_COMPLETE
GET_LEASE_TIME also has such a code structure, but it always waits
RETRY_MIN, not MAX


The first question, raised in the beginning of this mail:
Is it better to wait for the mutex in the NFSd thread (with the risk
of blocking that nfsd thread) or to return DELAY(with its 15s delay
and risk of repeatedly landing on a contended mutex even if it is not
kept locked the whole time)?
Is there some other solution?


The second question(s):
Why are there several different implementations of the same
restart/retry behaviors? why do some operations use one mechanism and
others use another?
Why isn't the exponential back-off mechanism used in these operations?
