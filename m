Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932582AbaLAXQy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 18:16:54 -0500
From: David Howells <dhowells@redhat.com>
To: jmorris@namei.org
cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, keyrings@linux-nfs.org,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] Keyrings (& NFS) fixes
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 01 Dec 2014 23:16:44 +0000
Message-ID: <5000.1417475804@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi James,

Can you pass these patches on to Linus please?

The first one fixes the handling of maximum buffer size for key descriptions,
fixing the size at 4095 + NUL char rather than whatever PAGE_SIZE happens to
be and permits you to read back the full description without it getting
clipped because some extra information got prepended.

The second and third fix a bug in NFS idmapper handling whereby a key
representing a mapping between an id and a name expires and causing
EKEYEXPIRED to be seen internally in NFS (which prevents the mapping from
happening) rather than re-looking up the mapping.

Thanks,
David
---
The following changes since commit 009d0431c3914de64666bec0d350e54fdd59df6a:

  Linux 3.18-rc7 (2014-11-30 16:42:27 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/keys-fixes-20141201

for you to fetch changes up to 0b0a84154eff56913e91df29de5c3a03a0029e38:

  KEYS: request_key() should reget expired keys rather than give EKEYEXPIRED (2014-12-01 22:52:53 +0000)

----------------------------------------------------------------
(from the branch description for keys-fixes local branch)

Keyrings fixes
Keyrings fixes

----------------------------------------------------------------
David Howells (3):
      KEYS: Fix the size of the key description passed to/from userspace
      KEYS: Simplify KEYRING_SEARCH_{NO,DO}_STATE_CHECK flags
      KEYS: request_key() should reget expired keys rather than give EKEYEXPIRED

 security/keys/internal.h         |  1 +
 security/keys/keyctl.c           | 56 +++++++++++++++++++---------------------
 security/keys/keyring.c          | 10 ++++---
 security/keys/request_key.c      |  2 ++
 security/keys/request_key_auth.c |  1 +
 5 files changed, 36 insertions(+), 34 deletions(-)
