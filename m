Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757611Ab2BHVTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 16:19:03 -0500
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 13/17] FS-Cache: Initialise the object event mask with the
 calculated mask
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2012 21:18:53 +0000
Message-ID: <20120208211853.15607.44641.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Initialise the object event mask with the calculated mask rather than unmasking
undefined events also.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/fscache/object.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index 80b5491..2ef8a08 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -114,7 +114,8 @@ static void fscache_object_state_machine(struct fscache_object *object)
 		/* wait for the parent object to become ready */
 	case FSCACHE_OBJECT_INIT:
 		object->event_mask =
-			ULONG_MAX & ~(1 << FSCACHE_OBJECT_EV_CLEARED);
+			FSCACHE_OBJECT_EVENTS_MASK &
+			~(1 << FSCACHE_OBJECT_EV_CLEARED);
 		fscache_initialise_object(object);
 		goto done;
 

