Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754927Ab3HARi4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 13:38:56 -0400
Subject: [RFC][PATCH 0/2] KEYS: Kerberos caching support
To: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org
From: David Howells <dhowells@redhat.com>
Cc: krbdev@mit.edu, linux-kernel@vger.kernel.org, simo@redhat.com
Date: Thu, 01 Aug 2013 18:38:46 +0100
Message-ID: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here are a couple of keyrings patches I'd like to propose to aid the support
for Kerberos to cache tickets in keys:

 (1) A large-capacity key type.

     This is a general purpose key type that can hold up to 1MB of data.  The
     data is stored in a SHM file and so can be stored out to swap if need be.

     I think it might be worth storing the data encrypted in the SHM file with
     a randomly generated transient symmetric key that the kernel creates and
     retains in memory for each key.  This would then be lost when the power
     went off, rendering the tickets irretrievable.

     This is necessary because some Kerberos tickets, particularly those
     returned by Windows Active Directory, for instance, can be huge, easily
     64KB or more, due to additional information stored in the ticket (the
     MS-PAC).

 (2) Per-user_namespace registers of per-UID kerberos caches.

     This allows the kerberos cache to be retained beyond the life of all a
     user's processes so that the user's cron jobs can work.

     The user asks for their Kerberos cache by:

	krb_cache = keyctl_get_krbcache(uid, dest_keyring);

     The uid is -1 or the user's own UID for the user's own cache or the uid
     of some other user's cache (requires CAP_SETUID).

     The cache returned is a keyring named "_krb.<uid>" that the possessor can
     read, search, clear, invalidate, unlink from and add links to.  SELinux
     and co. get a say as to whether this call will succeed as the caller must
     have LINK permission on the cache keyring.

     Each uid's cache keyring is created when it first accessed and is given a
     timeout that is extended each time this function is called so that the
     keyring goes away after a while.  The timeout is configurable by sysctl
     but defaults to 3 days.

     Each user_namespace gets a lazily-created keyring that serves as the
     register.  The cache keyrings are added to it.  This means that standard
     key search and garbage collection facilities are available.

     The user_namespace's register goes away when it does.

Note that these patches were constructed on top of my keyring capacity
expansion patches - but there shouldn't be much to change to apply them on top
of the vanilla kernel.

David
---
David Howells (2):
      KEYS: Implement a big key type that can save to tmpfs
      KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches


 include/keys/big_key-type.h    |   27 ++++++
 include/linux/key.h            |    1 
 include/linux/user_namespace.h |    6 +
 include/uapi/linux/keyctl.h    |    1 
 kernel/user.c                  |    4 +
 kernel/user_namespace.c        |    2 
 security/keys/Kconfig          |   23 +++++
 security/keys/Makefile         |    2 
 security/keys/big_key.c        |  181 ++++++++++++++++++++++++++++++++++++++++
 security/keys/compat.c         |    3 +
 security/keys/internal.h       |    9 ++
 security/keys/keyctl.c         |    3 +
 security/keys/krbcache.c       |  132 +++++++++++++++++++++++++++++
 security/keys/sysctl.c         |   11 ++
 14 files changed, 405 insertions(+)
 create mode 100644 include/keys/big_key-type.h
 create mode 100644 security/keys/big_key.c
 create mode 100644 security/keys/krbcache.c

