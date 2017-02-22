Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932924AbdBVWyl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 17:54:41 -0500
From: Jan Stancek <jstancek@redhat.com>
To: dhowells@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        jstancek@redhat.com, bcodding@redhat.com, asavkov@redhat.com
Subject: [PATCH 0/2] key payload access with just rcu_read_lock()
Date: Wed, 22 Feb 2017 23:54:25 +0100
Message-Id: <cover.1487802542.git.jstancek@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David,

this is a follow-up for "suspicious RCU usage" warning described
in these 2 linux-nfs threads:
  http://marc.info/?t=147558830300003&r=1&w=2
  http://marc.info/?t=148776770500001&r=1&w=2

Did you have something like in mind?

Thanks,
Jan

Jan Stancek (2):
  KEYS: add user_key_payload_rcu()
  NFS: use user_key_payload_rcu() in RCU read-side section

 Documentation/security/keys.txt | 5 +++++
 fs/nfs/nfs4idmap.c              | 2 +-
 include/keys/user-type.h        | 5 +++++
 include/linux/key.h             | 3 +++
 4 files changed, 14 insertions(+), 1 deletion(-)

-- 
1.8.3.1

