Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33483 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752390AbdCGNyr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 08:54:47 -0500
Received: by mail-qk0-f172.google.com with SMTP id y76so4649549qkb.0
        for <linux-nfs@vger.kernel.org>; Tue, 07 Mar 2017 05:54:23 -0800 (PST)
MIME-Version: 1.0
From: Satya Prakash GS <g.satyaprakash@gmail.com>
Date: Tue, 7 Mar 2017 19:15:57 +0530
Message-ID: <CAJZK4X7TpU=zk+u1q_aUByyYxQ-EWSSff8hcY+uATZSz+dKhcA@mail.gmail.com>
Subject: SUNRPC : Permission denied on NFS client with Kerberos enabled
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am running userspace NFS server (NFS Ganesha) with Kerberos enabled.
Intermittently iozone tests are failing on the nfs client with
"Permission denied" error. On seeing AUTH_REJECTEDCRED error I
expected the client to reestablish the context by sending
RPC_GSS_PROC_DESTROY/RPC_GSS_PROC_INIT.

Is destroy done as part of the gss_release_msg (gss_refresh_upcall ->
gss_setup_upcall -> gss_release_msg). If so, release is not called
when gss_msg == gss_new in gss_setup_call.

Nfs client logs when the operation fails (don't see destroy
context/free cred being called) :

Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 call_decode (status 20)
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 rpc_verify_header: retry
stale creds
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 invalidating RPCSEC_GSS
cred ffff88086f634b40
Mar  6 01:54:14 atsqa6c71 kernel: RPC:       freeing buffer of size
2496 at ffff88025a56b000
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 release request ffff8802d98a0e00
Mar  6 01:54:14 atsqa6c71 kernel: RPC:
wake_up_first(ffff880872a20320 "xprt_backlog")
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 call_reserve (status 0)
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 failed to lock transport
ffff880872a20000
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 sleep_on(queue
"xprt_sending" time 25925270030)
Mar  6 01:54:14 atsqa6c71 kernel: RPC: 49547 added to queue
ffff880872a20190 "xprt_sending"

...

Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 call_refresh (status 0)
Mar  6 01:54:59 atsqa6c71 kernel: RPC:       gss_create_cred for uid
0, flavor 390005
Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 refreshing RPCSEC_GSS
cred ffff8801c1c98c80
Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 gss_refresh_upcall for uid 0
Mar  6 01:54:59 atsqa6c71 kernel: RPC:       __gss_find_upcall found nothing
Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 sleep_on(queue
"RPCSEC_GSS upcall waitq" time 25925315305)
Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 added to queue
ffff88015a93a058 "RPCSEC_GSS upcall waitq"
Mar  6 01:54:59 atsqa6c71 kernel: RPC: 49547 gss_refresh_upcall for
uid 0 result 0
Mar  6 01:55:01 atsqa6c71 kernel: RPC:       __gss_find_upcall found
msg ffff88015a93a000
Mar  6 01:55:01 atsqa6c71 kernel: RPC:       krb5_encrypt returns 0
Mar  6 01:55:01 atsqa6c71 kernel: RPC:       krb5_encrypt returns 0
Mar  6 01:55:01 atsqa6c71 kernel: RPC:       krb5_encrypt returns 0
Mar  6 01:55:01 atsqa6c71 kernel: RPC:
gss_import_sec_context_kerberos: returning 0
Mar  6 01:55:01 atsqa6c71 kernel: RPC:       gss_fill_context Success.
gc_expiry 25955452747 now 25925316747 timeout 30136

In a scenario where the operation succeeds after hitting
AUTH_REJECTEDCRED error I see gss_free_cred, gss_delete_sec_context
being called.

I am not quite sure if this is a client bug or server bug. The server
is expecting RPC_GSS_PROC_INIT message when client refreshes the
credentials. Is the expectation right or am I missing something.

More details:

Userspace NFS Server is rejecting the operations with
AUTH_REJECTEDCRED because the credentials couldn't be found in the
cache. Server has an LRU for the credentials and it recycles them from
time to time.

Ideally it should throw RPCSEC_GSS_CREDPROBLEM instead of
AUTH_REJECTEDCRED error on not finding the credentials in the cache
(section 5.3.3.3 of rfc2203). However this shouldn't matter much as
both the errors are handled similarly on the client.

Client tolerates 3 errors but all the three calls failed because the
credentials were recycled for the first time and the credentials which
came as part of second/third retry weren't inserted in the cache. This
would happen if the client doesn't send RPC_GSS_PROC_INIT when it
refreshed the credentials.

Thanks,
Satya.
