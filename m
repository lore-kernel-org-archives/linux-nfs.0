Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41968 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753791AbcI2Pnw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 11:43:52 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 97BEE68803
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 15:43:51 +0000 (UTC)
Received: from hut.sorensonfamily.com.redhat.com (ovpn-116-43.rdu2.redhat.com [10.10.116.43])
        by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u8TFhoxB007382
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 11:43:51 -0400
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Add auth-specific auth_cred hash functions
Date: Thu, 29 Sep 2016 10:44:36 -0500
Message-Id: <1475163881-12438-1-git-send-email-sorenson@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, a single hash algorithm is used to hash the auth_cred
for lookup in the credcache for all rpc_auth flavors.  Only the
uid is included in the value to be hashed.

For AUTH_SYS, rpc_creds created with the same uid but different
gids will all go on the same hash chain.  In certain usage patterns,
such as the following, this can lead to extremely long hash chains
and slow performance for certain uids.

    for (i = 0 ; i < 100000 ; i++) {
        setregid(-1, i);
        stat(path, &st);
    }

With AUTH_SYS, in order to distribute the rpc_creds more evenly
throughout the cache, we want to include the gid in the hash.

However, since the gid is not relevant or appropriate for all
auth flavors, we need to provide hash functions specific to each
auth flavor.  Do this by adding a 'hash_cred' function to the
rpc_authops stuct, and having rpcauth_lookup_credcache call a
hash function created for each flavor.

As a performance comparison for unix_auth, with a credcache
containing 100,000 entries, hashing both the uid and gid reduces
the time to complete an 'ls' of a single directory containing 1000
files from over 8 1/2 minutes to 4 1/2 seconds.


Signed-off-by: Frank Sorenson <sorenson@redhat.com>

Frank Sorenson (5):
  sunrpc: add hash_cred() function to rpc_authops struct
  sunrpc: add generic_auth hash_cred() function
  sunrpc: add auth_unix hash_cred() function
  sunrpc: add RPCSEC_GSS hash_cred() function
  sunrpc: replace generic auth_cred hash with auth-specific function

 include/linux/sunrpc/auth.h    | 1 +
 net/sunrpc/auth.c              | 2 +-
 net/sunrpc/auth_generic.c      | 9 +++++++++
 net/sunrpc/auth_gss/auth_gss.c | 7 +++++++
 net/sunrpc/auth_unix.c         | 9 +++++++++
 5 files changed, 27 insertions(+), 1 deletion(-)

-- 
2.5.5

