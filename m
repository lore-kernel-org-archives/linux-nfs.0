Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926ECC10F05
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 68A8A21928
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 16:56:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2395362AbfBNQ4n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 11:56:43 -0500
Received: from mx1.redhat.com ([209.132.183.28]:9047 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728698AbfBNQ4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 11:56:43 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 46BF23C2CD0;
        Thu, 14 Feb 2019 16:56:43 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A958E600C1;
        Thu, 14 Feb 2019 16:56:39 +0000 (UTC)
Subject: [RFC PATCH 0/9] keys: Namespacing
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Thu, 14 Feb 2019 16:56:38 +0000
Message-ID: <155016339876.11489.901851271827069026.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 14 Feb 2019 16:56:43 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Here are some development patches to make keys and keyrings namespace aware by
the following means:

 (1) Firstly some miscellaneous patches to make it simpler:

     (a) Invalidate rather than revoke request_key() authentication keys to
     	 recycle them more quickly.

     (b) Remove request_key_async*() as they aren't used and would have to be
     	 namespaced.

     (c) Simplify key index_key handling so that the word-sized chunks
     	 assoc_array requires don't have to be shifted about, making it easier
     	 to add more bits into the key.

     (d) Cache the hash value so that we don't have to calculate on every key
     	 we examine during a search (it involves a bunch of multiplications).

     [Note: Some of these want to be split out and sent separately]

 (2) Make it possible to include the target namespace in which the key shall
     operate in the index_key.  This will allow the possibility of multiple
     keys with the same description, but different target domains to be held
     in the same keyring.

 (3) Make it so that keys are effectively invalidated by removal of a domain
     tag, causing them to be garbage collected.

 (4) Institute a network namespace domain tag that allows keys to be
     differentiated by the network namespace in which they operate.  New keys
     that are of a type marked 'KEY_TYPE_NET_DOMAIN' are assigned the network
     domain in force when they are created.

 (5) Make it so that the desired network namespace can be handed down into the
     request_key() mechanism.  This allows AFS, NFS, etc. to request keys
     specific to the network namespace of the superblock.

     This also means that the keys in the DNS record cache are thenceforth
     namespaced, provided network filesystems pass the appropriate network
     namespace down into dns_query().

     For DNS, AFS and NFS are good; CIFS and Ceph are not.  Other cache
     keyrings, such as idmapper keyrings, also need to set the domain tag.

 (6) Make it so that keyring names are per-user-namespace so that they're not
     accessible cross-user-namespace.


The patches can be found on the following branch:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=keys-namespace

David
---
David Howells (9):
      keys: Invalidate used request_key authentication keys
      keys: Kill off request_key_async{,_with_auxdata}
      keys: Simplify key description management
      keys: Cache the hash value to avoid lots of recalculation
      keys: Include target namespace in match criteria
      keys: Garbage collect keys for which the domain has been removed
      keys: Network namespace domain tag
      keys: Pass the network namespace into request_key mechanism
      KEYS: Namespace keyring names


 fs/afs/addr_list.c             |    4 -
 fs/afs/dynroot.c               |    7 +
 fs/cifs/dns_resolve.c          |    3 
 fs/nfs/dns_resolve.c           |    2 
 include/linux/dns_resolver.h   |    3 
 include/linux/key-type.h       |    3 
 include/linux/key.h            |   46 ++++++-
 include/linux/user_namespace.h |    5 +
 include/net/net_namespace.h    |    4 +
 kernel/user.c                  |    3 
 kernel/user_namespace.c        |    7 +
 net/ceph/messenger.c           |    3 
 net/core/net_namespace.c       |   18 +++
 net/dns_resolver/dns_key.c     |    1 
 net/dns_resolver/dns_query.c   |    6 +
 net/rxrpc/key.c                |    6 +
 security/keys/gc.c             |    2 
 security/keys/internal.h       |    6 +
 security/keys/key.c            |    9 +
 security/keys/keyctl.c         |    2 
 security/keys/keyring.c        |  248 ++++++++++++++++++++++------------------
 security/keys/persistent.c     |    2 
 security/keys/request_key.c    |   90 +++++++--------
 23 files changed, 288 insertions(+), 192 deletions(-)

