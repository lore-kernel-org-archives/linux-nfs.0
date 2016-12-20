Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46874 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752117AbcLTACa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Dec 2016 19:02:30 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <neilb@suse.de>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3] SVCAUTH update the rsc cacue on RPC_GSS_PROC_DESTROY
Date: Mon, 19 Dec 2016 19:00:29 -0500
Message-ID: <1482192030-19219-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

I instrumented cache_get, cache_put, cache_clean, svcauth_cache_lookup
and svcauth_gss_accept.

Then I mounted -o sec=krb5, listed the mount directory, and umounted.

CASE 1: Here is the instrumented output without the patch:

svcauth_gss_accept gc_proc 3 rq_proc 0  (process RPC_GSS_PROC_DESTROY)
--> sunrpc_cache_lookup from rsc_lookup key ffffc90002b9bc58 hash 940
sunrpc_cache_lookup 1 calling cache_get key ffffc90002b9bc58 tmp
ffff880079b3f500
--> cache_get h ffff880079b3f500 refcount 1
sunrpc_cache_lookup RETURN 1  key ffffc90002b9bc58 tmp ffff880079b3f500
--> rsc_free h ffffc90002b9bc58

&rsci->h is ffff880079b3f500, which identifies the cache entry we want
destroyed.

Case: RPC_GSS_PROC_DESTROY:
svcauth_gss_accept RPC_GSS_PROC_DESTROY h ffff880079b3f500 ref 2
expiry 1481823331 <<<<<
svcauth_gss_accept AFTER SETTING h ffff880079b3f500 expiry 1481819736   <<<<<<<

Note: expiry_time (and CACHE_NEGATIVE) are set.

END of svcauth_gss_accept:
svcauth_gss_accept END calling cache_put h ffff880079b3f500
--> cache_put h ffff880079b3f500 refcount 2 cd->cache_put ffffffffa045c180
Dec 15 11:35:36 rhel7-2-ga-2 kernel: <-- cache_put h ffff880079b3f500 refcount 1

refcount is 1, but cache_clean is not setup to reap the entry as
rsc_update was not called. Besides using the write_lock (which should
be used for entry changes) rsc_update also sets other fields to
trigger cache_clean to remove the entry from the cache_list under
the write_lock and do a final cache_put.


cache_clean CLEAN h ffff880079b3e540 h->expiry_time 1481819736 hash 982

The above cache_clean occurs about 45 minutes after the END
svcauth_gss_accept cache_put.

I waited about 2 hours, and the cache entry was still not reaped
even though the expiry time was set.


CASE 2: Here is the instrumented output with the patch:

svcauth_gss_accept gc_proc 3 rq_proc 0  (process RPC_GSS_PROC_DESTROY)
--> sunrpc_cache_lookup from rsc_lookup key ffffc90002befc30 hash 982
sunrpc_cache_lookup calling cache_get key ffffc90002befc30 tmp ffff88006fcc6cc0
--> cache_get h ffff88006fcc6cc0 refcount 1
sunrpc_cache_lookup RETURN 1  key ffffc90002befc30 tmp ffff88006fcc6cc0
--> rsc_free h ffffc90002befc30

&rsci->h is ffff88006fcc6cc0, which identifies the cache entry we want
destroyed.

Case: RPC_GSS_PROC_DESTROY:
svcauth_gss_accept RPC_GSS_PROC_DESTROY h ffff88006fcc6cc0 ref 2 
--> rsc_update new h ffffc90002befd18 new ref 0 old h ffff88006fcc6cc0 old ref 2
--> update_rsc new->h ffff88006fcc6cc0 tmp->h ffffc90002befd18

END of svcauth_gss_accept:
svcauth_gss_accept END calling cache_put h ffff88006fcc6cc0
--> cache_put h ffff88006fcc6cc0 refcount 2 cd->cache_put ffffffffa03cd170
<-- cache_put h ffff88006fcc6cc0 refcount 1

refcount is 1, setup for cache_clean.

cache_clean CLEAN h ffff88006fcc6cc0 h->expiry_time 0 hash 982
cache_clean DELETE h ffff88006fcc6cc0 from cache_list
cache_clean CLEANED calling cache_put h ffff88006fcc6cc0
--> cache_put h ffff88006fcc6cc0 refcount 1 
--> rsc_put PUT h ffff88006fcc6cc0
--> rsc_free h ffff88006fcc6cc0
 <-- cache_put h ffff88006fcc6cc0 refcount 0

The cache entry is destroyed.


Andy Adamson (1):
  SVCAUTH update the rsc cache on RPC_GSS_PROC_DESTROY

 net/sunrpc/auth_gss/svcauth_gss.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

-- 
1.8.3.1

