Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab3GQUn0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jul 2013 16:43:26 -0400
Subject: [RFC][PATCH 00/10] Associative array & Massive expansion of keyring
 capacity
To: keyrings@linux-nfs.org
From: David Howells <dhowells@redhat.com>
Cc: linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 17 Jul 2013 21:43:14 +0100
Message-ID: <20130717204314.8591.52892.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Here's a set of patches that do two main things:

 (1) Provide a general purpose associative array implementation.

 (2) Use the associative array implementation to provide key pointer storage
     for keyrings thereby massively increasing capacity.

There are numerous smaller patches also that are split out of (2) to make the
patch in (2) smaller, plus a fix patch that didn't get taken into the last
merge window.

The patches can also be found at:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=keys-devel


The impetus for these is that the NFS ID mapper uses keyrings to store name to
ID mappings, but is running up against the limitation imposed by the flat
array currently used by the keyring.

The associative array implementation does all the work.  To quickly summarise
its capabilities: no capacity limit; objects don't need to be modified to go
in it (no list_head/rb_node equivalent needed); objects need a unique index
key of arbitrary length; objects can be anything; modifications are generally
RCU-safe; the contents can be iterated over and it can directly walk to an
object in O(log(N)-ish) time given the key; and lastly, there are several
features to reduce the memory footprint (node sharing and shortcuts).
Documentation is included in the patch.

Note that the associative array implementation was developed in userspace and
has been thoroughly valground and tested inserting new objects whilst
iterating over 2,000,000 objects amongst other things.

The keyutils testsuite has been run successfully against a kernel with these
patches applied, though the testsuite did need some tweaks: (a) previously
keys added to a keyring with no removals appeared to be ordered and (b) some
of the errors have changed.

David
---
David Howells (10):
      KEYS: Skip key state checks when checking for possession
      Add a generic associative array implementation.
      KEYS: Use bool in make_key_ref() and is_key_possessed()
      KEYS: key_is_dead() should take a const key pointer argument
      KEYS: Consolidate the concept of an 'index key' for key access
      KEYS: Introduce a search context structure
      KEYS: Search for auth-key by name rather than targt key ID
      KEYS: Define a __key_get() wrapper to use rather than atomic_inc()
      KEYS: Drop the permissions argument from __keyring_search_one()
      KEYS: Expand the capacity of a keyring


 Documentation/assoc_array.txt    |  583 +++++++++++++
 Documentation/security/keys.txt  |   20 
 include/keys/keyring-type.h      |   17 
 include/linux/assoc_array.h      |   94 ++
 include/linux/assoc_array_priv.h |  159 +++
 include/linux/key-type.h         |    5 
 include/linux/key.h              |   48 +
 lib/Kconfig                      |   14 
 lib/Makefile                     |    1 
 lib/assoc_array.c                | 1734 ++++++++++++++++++++++++++++++++++++++
 security/keys/Kconfig            |    1 
 security/keys/gc.c               |   30 -
 security/keys/internal.h         |   65 +
 security/keys/key.c              |   91 +-
 security/keys/keyring.c          | 1447 ++++++++++++++++----------------
 security/keys/proc.c             |   17 
 security/keys/process_keys.c     |  131 +--
 security/keys/request_key.c      |   56 +
 security/keys/request_key_auth.c |   31 -
 security/keys/user_defined.c     |   18 
 20 files changed, 3596 insertions(+), 966 deletions(-)
 create mode 100644 Documentation/assoc_array.txt
 create mode 100644 include/linux/assoc_array.h
 create mode 100644 include/linux/assoc_array_priv.h
 create mode 100644 lib/assoc_array.c

