Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35997 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755253Ab3FCBA4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 21:00:56 -0400
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Mon, 03 Jun 2013 11:00:21 +1000
Subject: [PATCH 1/3] krb5_utils: remove redundant array size.
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Message-ID: <20130603010021.20080.24416.stgit@notabene.brown>
In-Reply-To: <20130603005219.20080.1927.stgit@notabene.brown>
References: <20130603005219.20080.1927.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When initialising an array there is no need to specify the size as the
size is taken from the initialiser.  Having the size there means that
any change to the initialiser needs to change the size to and so is
error-prone.

So just remove the size.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/gssd/krb5_util.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6275dd8..9ef80f0 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1236,7 +1236,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 	krb5_keytab kt = NULL;;
 	int retval = 0;
 	char *k5err = NULL;
-	const char *svcnames[5] = { "$", "root", "nfs", "host", NULL };
+	const char *svcnames[] = { "$", "root", "nfs", "host", NULL };
 
 	/*
 	 * If a specific service name was specified, use it.


