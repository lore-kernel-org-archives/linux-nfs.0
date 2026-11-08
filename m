Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794176848;
	b=EfI1RifkS1B7Ueq2T9yRegTFmqBjroY9YzxWu34QCs8Skrzw3Phkzgssmxjv3GvlX8a5
	 +sYaQc53U9TBJrvF8atAg9Mc917URTlMK/no2tK4fhxKlC7UprtByikZRnAzsQCfpCgF4
	 E2V3GpB1k7P71p22AoLTYsNfSMn55db61yKnZkNJLSEvkI/DiCJxy2CqvA9F6cXO2rTL+
	 FKIo9VvXF+CFGjgq19OqC5Rcs2bBpsvYcVXAZ850Gu7EwDI1KKYji2EeArHQtFpEDBhlM
	 oxBE7bsgC4Sum0M99bFiLXoe8YF2DGMeg0nbrCz0Z7V98pz+YR4HwyjxzIOvoagBvsQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794176848;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=9wA76Ik20K3lvmoeTnCYt3jGXsckv8iSIGtPrk9V5HM=;
	b=AEHnG8hZkOJzKCpIQO7zEAswqa6pCtVtf88jUrN8AJN8nnSsGz59hyrTfdOYEFUD7htO
	 l8QG8R69dN0eeR8ERzjs/tFtbIHDuu6psacJftzzqqeW2+QqN9Q35X2dtDCJ+k9iXZzZY
	 mVz4Nzlsjn4hH3KmeV+tR+BeuQsdXrTFVE08plevWvKgPcw1OeR9tFv+SiCGFtt05cfjk
	 jO+zk7e9OAQoaAmg/wOYBGvf7RkRKFVsnKt6jq935M0Oj32TdKOD7r/iwn2RhbjiZWGBC
	 lVJMRdRmXU2B6KJFM06xve5Rrktd4CmxS4V1/Keyw+FtI5myOlhafhgBZx1YQwHl21w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MHl5J7z5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id CCB0B606A320;
	Sun,  8 Nov 2026 22:27:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MHl5J7z5
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id A600F1F0089F;
	Sun,  8 Nov 2026 22:27:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794176847;
	bh=9wA76Ik20K3lvmoeTnCYt3jGXsckv8iSIGtPrk9V5HM=;
	h=From:To:Cc:Subject:Date;
	b=MHl5J7z5FLE/MYQrhxhKA/lulPvbS7q685tHJM7Gh3QJmWCgTDE/DWCS2RThfUP7m
	 77dyu3egSp5CaaPvG/rj5/bSFkd+tF1np+qlly9Bq/SkByftwl2GkbcHPFOEl2CDkh
	 wC6I2C4GZtDoDkvtwIKO8RprOWzqqWe+ajHGi/tZdLcKfuqML6rfXAYdNjHXtZgec5
	 SkFuAYYL9bZnLswpKwnYWOc1b/TS/Tdk3PqrzQrjXgIFGKJZWP65P6KcSFVAlyX9Xf
	 XrBM5lx+ZFFUoLPyGWVnj8DmXa8JMxzZJVRvYsoJmV3S4TEGAUYr2i80c50qwkHKRG
	 FnrPkPPEExM9w==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [PATCH v5 00/12] KEYS: Sanitize the garbage collector
Date: Mon,  9 Nov 2026 00:27:06 +0200
Message-ID: <20261108222719.304712-1-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

1. Replace key_type_dead retyping with module reference pinning so live
   keys and restrictions keep their backing key_type module loaded until
   key_gc_unused_keys() or keyring_destroy() completes.
2. Process serial-tree scans and graveyard destruction in fixed 64-key
   chunks to a bound workqueue execution latency without hurting overall
   throughput for a significant amount.

The first part has a user-space visible effect: rmmod returns -EBUSY while
keys or keyring restrictions still pin the backing module.

Internal key caches or transport state bottlenecks are addressed by either
clearing their private caches on last-client teardown or splitting key
types into dedicated provider modules.

CHANGES
=======

v5:
- Another round of fixes resolving Sashiko remarks.
- Reordered TEE session lifetime synchronization patch before suppressing
  sysfs bind attributes.
- Release conn->key in rxrpc_process_event() on init_connection_security()
  failure
- Update Documentation/networking/rxrpc.rst to reference
  net/rxrpc/security.c instead of net/rxrpc/server_key.c.
- Store the delay-adjusted reap timestamp in gc->end in
  key_garbage_collector() instead of recording unadjusted key->expiry and
  adding key_gc_delay a second time.

v4:
- Replaced WARN_ON() around fallible keyring_clear() in CIFS idmap and
  SPNEGO cache-clearing helpers with pr_warn_ratelimited().
- Moved key garbage collection from the shared events workqueue onto a
  dedicated WQ_MEM_RECLAIM | WQ_PERCPU workqueue (key_gc), allocated in
  key_init(), so WQ_MEM_RECLAIM workers (nfsiod/cifsiod) and reclaim paths
  can flush key GC safely.

v3:
- Split dns_resolver and rxrpc key types into dedicated provider modules
  (dns_resolver_key.ko and rxrpc_keys.ko) instead of client refcounting,
  so cached or retained keys do not pin dns_resolver.ko or rxrpc.ko.
- Dropped the standalone nvme-keyring fix as it was picked up by the
  subsystem maintainers.
- Hardened key_gc_flush() to serialize against chunked key_gc_work
  continuations, and fixed a restriction module reference leak on failed
  keyring instantiation.

v2:
- Used v1 as a test probe for Sashiko to detect the corner cases instead
  of trying to resolve even the known ones beforehand.
- Converted the client subsystems to be compatible with the module
  pinning semantics.

VERSIONS
========

- v4:
  https://lore.kernel.org/keyrings/20261107131512.3603168-1-jarkko@kernel.org/
- v3:
  https://lore.kernel.org/keyrings/20261105005311.804098-1-jarkko@kernel.org/
- v2:
  https://lore.kernel.org/linux-integrity/20261103030226.2685251-1-jarkko@kernel.org/

Cc: keyrings@vger.kernel.org
Cc: linux-afs@lists.infradead.org
Cc: linux-cifs@vger.kernel.org
Cc: linux-integrity@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: linux-s390@vger.kernel.org
Cc: linux-security-module@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: Alexander Gordeev <agordeev@linux.ibm.com>
Cc: Anna Schumaker <anna@kernel.org>
Cc: Bharath SM <bharathsm@microsoft.com>
Cc: Christian Borntraeger <borntraeger@linux.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Biggers <ebiggers@kernel.org>
Cc: Eric Dumazet <edumazet@kernel.org>
Cc: Heiko Carstens <hca@linux.ibm.com>
Cc: Jakub Kicinski <kuba@kernel.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: James Morris <jmorris@namei.org>
Cc: Jarkko Sakkinen <jarkko@kernel.org>
Cc: Marc Dionne <marc.dionne@auristor.com>
Cc: Mimi Zohar <zohar@linux.ibm.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Paulo Alcantara <pc@manguebit.org>
Cc: Ronnie Sahlberg <ronniesahlberg@gmail.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>
Cc: Shyam Prasad N <sprasad@microsoft.com>
Cc: Simon Horman <horms@kernel.org>
Cc: Sumit Garg <sumit.garg@kernel.org>
Cc: Sven Schnelle <svens@linux.ibm.com>
Cc: Tom Talpey <tom@talpey.com>
Cc: Trond Myklebust <trondmy@kernel.org>
Cc: Vasily Gorbik <gor@linux.ibm.com>

Jarkko Sakkinen (12):
  KEYS: Add key_gc_flush() for draining RCU callbacks
  dns_resolver: Move the key type into a separate module
  NFSv4: Clear idmap keyring cache when the last client unloads
  smb: client: Clear idmap/SPNEGO caches when the last session is
    unloaded
  s390/cert_store: Start tracking subsystem keys
  KEYS: trusted: TEE: Synchronize session lifetime
  KEYS: trusted: TEE: Disable sysfs bind attributes
  rxrpc: Release conn->key when init_connection_security() fails
  rxrpc: Move key types to their own module
  KEYS: Pin the backing kernel module for a key type
  KEYS: Remove key_type_dead
  KEYS: key_garbage_collector(): process in chunks

 Documentation/networking/rxrpc.rst        |   2 +-
 arch/s390/kernel/cert_store.c             | 161 +++++-------
 fs/nfs/nfs4idmap.c                        |  21 ++
 fs/smb/client/cifs_spnego.c               |  12 +
 fs/smb/client/cifsacl.c                   |  12 +
 fs/smb/client/cifsproto.h                 |   8 +
 fs/smb/client/misc.c                      |  19 +-
 include/linux/key-type.h                  |   6 +-
 include/linux/key.h                       |   2 +
 net/Makefile                              |   4 +-
 net/dns_resolver/Kconfig                  |  15 ++
 net/dns_resolver/Makefile                 |   4 +-
 net/dns_resolver/dns_key.c                |  65 +----
 net/dns_resolver/dns_query.c              |  64 +++++
 net/dns_resolver/internal.h               |   5 -
 net/rxrpc/Kconfig                         |  20 ++
 net/rxrpc/Makefile                        |   7 +-
 net/rxrpc/af_rxrpc.c                      |  19 +-
 net/rxrpc/ar-internal.h                   |  25 +-
 net/rxrpc/conn_event.c                    |   7 +-
 net/rxrpc/key.c                           | 122 +++------
 net/rxrpc/proc.c                          |   2 +-
 net/rxrpc/rxgk.c                          |  66 -----
 net/rxrpc/rxkad.c                         |  47 ----
 net/rxrpc/security.c                      | 184 ++++++++++++++
 net/rxrpc/server_key.c                    | 260 +++++++++++--------
 security/keys/gc.c                        | 289 ++++++++++------------
 security/keys/internal.h                  |   8 +-
 security/keys/key.c                       |  65 +++--
 security/keys/keyring.c                   |  88 +++----
 security/keys/trusted-keys/trusted_core.c |  15 +-
 security/keys/trusted-keys/trusted_tee.c  |  89 +++++--
 32 files changed, 932 insertions(+), 781 deletions(-)

--
2.47.3

