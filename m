Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48597 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab2BHLDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 06:03:12 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/9] keys: update the description with info about "logon" keys
To: steved@redhat.com, jmorris@namei.org
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Wed, 08 Feb 2012 11:03:06 +0000
Message-ID: <20120208110306.4050.46104.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
References: <20120208110254.4050.8856.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/security/keys.txt |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/Documentation/security/keys.txt b/Documentation/security/keys.txt
index 713ec23..be3d229 100644
--- a/Documentation/security/keys.txt
+++ b/Documentation/security/keys.txt
@@ -123,7 +123,7 @@ KEY SERVICE OVERVIEW
 
 The key service provides a number of features besides keys:
 
- (*) The key service defines two special key types:
+ (*) The key service defines three special key types:
 
      (+) "keyring"
 
@@ -137,6 +137,19 @@ The key service provides a number of features besides keys:
 	 blobs of data. These can be created, updated and read by userspace,
 	 and aren't intended for use by kernel services.
 
+     (+) "logon"
+
+         Like a "user" key, a "logon" key has a payload that is an arbitrary
+         blob of data. It is intended as a place to store secrets that the
+         to which the kernel should have access but that should not be
+         accessable from userspace.
+
+         The description can be arbitrary, but must be prefixed with a non-zero
+         length string that describes the key "subclass". The subclass is
+         separated from the rest of the description by a ':'. "logon" keys can
+         be created and updated by userspace, but the payload is only readable
+         from kernel space.
+
  (*) Each process subscribes to three keyrings: a thread-specific keyring, a
      process-specific keyring, and a session-specific keyring.
 

