Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbbE0SBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 May 2015 14:01:33 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (Postfix) with ESMTPS id 7F0408E694
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 18:01:33 +0000 (UTC)
Received: from bcodding-csb.redhat.com (vpn-55-212.rdu2.redhat.com [10.10.55.212])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t4RI1X33015072
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2015 14:01:33 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs 1/3] Fix default arg order error on swig > 1.x
Date: Wed, 27 May 2015 14:01:30 -0400
Message-Id: <72bd55393455ddd1cfba7902e9136b92b87b9a7b.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
In-Reply-To: <cover.1432749206.git.bcodding@redhat.com>
References: <cover.1432749206.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The gssapi.py module ends up with
def initSecContext(name, context=None, INPUT=0, cred=0, mech, flags=2, time=0, chan=0):

which creates the error "SyntaxError: non-default argument follows default
argument" on import.  Revert to earlier swig behavior of using compact
default args.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 gssapi/gssapi.i |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/gssapi/gssapi.i b/gssapi/gssapi.i
index 5b66ce0..28656c7 100644
--- a/gssapi/gssapi.i
+++ b/gssapi/gssapi.i
@@ -487,6 +487,7 @@ OM_uint32 reordered_init_sec_context
 %apply gss_buffer_t OUTPUT {gss_buffer_t token};
 %apply OM_uint32 *OUTPUT {OM_uint32 *flags, OM_uint32 *time};
 %feature("autodoc", "initSecContext(gss_name_t name, gss_ctx_id_t *context=None, string token=None, gss_cred_id_t cred=None, gss_OID mech=krb5oid, int flags=0, int time=0, gss_channel_bindings_t chan=None) -> context, mech, token, flags, time");
+%feature("compactdefaultargs");
 OM_uint32 reordered_init_sec_context
 	        (OM_uint32 *minor,		/* minor_status */
 		 gss_name_t name,			/* target_name IN*/
@@ -507,6 +508,7 @@ OM_uint32 reordered_init_sec_context
 %clear gss_OID *mech;
 %clear gss_buffer_t token;
 %clear OM_uint32 *flags, OM_uint32 *time;
+%feature("compactdefaultargs", 0);
 
 /********/
 
-- 
1.7.1

