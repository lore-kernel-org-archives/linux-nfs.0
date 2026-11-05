Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840000;
	b=EgW++X8NSUHY8mYRujZStt1bOcf7ip/MEQxYTfNv8u1y2vObluumbo1/Pf05anmPD59B
	 q9vobClNpiWpPOCMm6CKBaBdoBIO/t0xjQGuJ9Q/1Iwq3hYCUuAMIaQaclAIUI+UNYYln
	 5skhrOXFTQa9ogqB0WIGr2sybBnAsS2DvMfBz0Wkuh6iVxVUk4wpb3dbbVzwoIeMRvd70
	 bnLxSN0s2qv83jWgq0HbkeqlrFxDVaeESZHeN19YtD2XR7lwXqtxGImW60QznRUThBRTw
	 tgimSunUxTwmxwYmic+feYZi4TT2Wj7gI1SHLDWyzMry3W5opVtkJ3I9Q3fapClKQ/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840000;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=VRz/fr2W5XuC5uSGQ1HwHlJlRaYB2g29XfbHOGVqqEg=;
	b=pm5mI5cER6W4gFqZE9n1CroOs7wYCYqecSSkJjpb8Z68gaQWOkhCrZgijIDAExBhzlhX
	 brnUF+e8VS6ltqWRds8oh/BaxqhDfk880TD87VUu350Z7rZ/B9HbMz/eg5oM4pWVeqHbZ
	 4sSEp87GDM/Z7Ak5K2hOctJPyEzXGSdiKYHriuKQhE/6zDDkeQmA4eusomfnftFHfhy/9
	 mwys7UAz9mMgu66vuq1KX279cigCug0SzqqwTioLrJYn//KSbF5u3fxKk3dcj9GBwg/Cq
	 oIqx5SpLYAbev/qjFI8sfWCgbkCTsz2mratJS9CkqndBSXPx3tp6AuHcgWQHaAS365g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=biGpPmbr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 514EC606A31B;
	Thu,  5 Nov 2026 00:53:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=biGpPmbr
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 240B21F000C1;
	Thu,  5 Nov 2026 00:53:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793839999;
	bh=VRz/fr2W5XuC5uSGQ1HwHlJlRaYB2g29XfbHOGVqqEg=;
	h=From:To:Cc:Subject:Date;
	b=biGpPmbr7mxbjpmYiMiR7S0h+DjiNBCcSJhGp65qcu7SPBIZ9i/YqIulnrwG0sr50
	 jYlfxviw16RWhT/60c2g2iu69BB5l2NsJ9QRlw+Zhwnl5XFGSOodjTZ1887uKu6DuE
	 yjvxfaOffAc0oDY6QPn6bZyXQEt8sCQr7BYNoXiQcfASKiwiNi9Yt//h5o4EZn7G9e
	 RgU0RWTEmjjSIdxMgRHs5XmLlLfeDwl4pV5fDIp1JVmzna/j7b9ELvTf5UY2kQg2XO
	 O8RgV4KPvvIEUAaV5nV7A97Ud9lo2sSix9k8hiJvfy0UgT2w6CoDWaKeUHfxDL67q6
	 iZs3gcyLwkePA==
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
	samba-technical@lists.samba.org,
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
Subject: [RFC PATCH v3 00/11] KEYS: Sanitize the garbage collector
Date: Thu,  5 Nov 2026 02:52:59 +0200
Message-ID: <20261105005311.804098-1-jarkko@kernel.org>
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
Cc: samba-technical@lists.samba.org
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

Jarkko Sakkinen (11):
  KEYS: Add key_gc_flush() for draining RCU callbacks
  dns_resolver: Move the key type into a separate module
  NFSv4: Clear idmap keyring cache when the last client unloads
  smb: client: Clear idmap/SPNEGO caches when the last session is
    unloaded
  s390/cert_store: Start tracking subsystem keys
  KEYS: trusted: TEE: Disable sysfs bind attributes
  KEYS: trusted: TEE: Synchronize session lifetime
  rxrpc: Move key types to their own module
  KEYS: Pin the backing kernel module for a key type
  KEYS: Remove key_type_dead
  KEYS: key_garbage_collector(): process in chunks

 arch/s390/kernel/cert_store.c             | 161 +++++-------
 fs/nfs/nfs4idmap.c                        |  21 ++
 fs/smb/client/cifs_spnego.c               |   6 +
 fs/smb/client/cifsacl.c                   |   6 +
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
 net/rxrpc/key.c                           | 122 +++------
 net/rxrpc/rxgk.c                          |  66 -----
 net/rxrpc/rxkad.c                         |  47 ----
 net/rxrpc/security.c                      | 184 ++++++++++++++
 net/rxrpc/server_key.c                    | 260 ++++++++++++--------
 security/keys/gc.c                        | 287 ++++++++++------------
 security/keys/internal.h                  |   7 +-
 security/keys/key.c                       |  61 +++--
 security/keys/keyring.c                   |  88 +++----
 security/keys/trusted-keys/trusted_core.c |  15 +-
 security/keys/trusted-keys/trusted_tee.c  |  89 +++++--
 29 files changed, 906 insertions(+), 777 deletions(-)

--
2.47.3

