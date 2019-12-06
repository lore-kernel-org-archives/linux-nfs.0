Return-Path: <SRS0=sXPk=Z4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C87DBC43603
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Dec 2019 18:29:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92C552173E
	for <linux-nfs@archiver.kernel.org>; Fri,  6 Dec 2019 18:29:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="gekcsW34"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726315AbfLFS3b (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 6 Dec 2019 13:29:31 -0500
Received: from mail-ua1-f43.google.com ([209.85.222.43]:44658 "EHLO
        mail-ua1-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726312AbfLFS3b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2019 13:29:31 -0500
Received: by mail-ua1-f43.google.com with SMTP id d6so3205407uam.11
        for <linux-nfs@vger.kernel.org>; Fri, 06 Dec 2019 10:29:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=sYT+ovaTSSagWO1yvrcdGm8CLAJh34XedQbfm1wHlWI=;
        b=gekcsW347N3xjQtMe/MVIaU6dFJnnUenPwVgJyUIj5+oSc0ni0dMGl0AhqOTHOsdOh
         QI92pHzWFjZvgca/RpmYgFRGkbL7BIVQQb0cq1Qg+a0SpJjDhpozFXk+E0eZmyaaQrN8
         vHJb1W5NYJTs/aWAbq4/UgqFtUPJOc2AAp71eWdE2vOtHzh3W4qY8Lozegd9GhDJYKkB
         XovAaCtZlueZ4OiykYimglUYufIgMK0+5zafdqKIYwous/zZbd0QALlALr8IMJOZSuOC
         Hh+KeQd5nhfRW0Ps59C2BlRn7XJnfhxvFXZ0issFea+ZIjqwAatGTofAZs1Zi0HgwZ4K
         j2Xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=sYT+ovaTSSagWO1yvrcdGm8CLAJh34XedQbfm1wHlWI=;
        b=oMPNs4pdzS68rYQmo9s7te1WXc+mb951hlWxp4bWRdqtfdcxjs0obtx1sKBpM4ukpO
         zPlhYsCt8f96EhGo+btQ9nVHb6/jn/JeecSydFph6lFzpMK+v1bCng/WlLUDQtCx+jIE
         T4SsAkrsyHFmDb11rLyEPlIx+bCKIfvHYEy86UKW/SPwyMQbIGLJBlCdxQyCLKWQDFjM
         /onK6WHEGZC3hJ4G//Jk0fqGxOp8VHyIdgCe8tmQxHGbL1TMHUaz8teT4spRHIsslF7l
         qVuax7JATf5AiVIKLhkEY4HQBRi8pp5+ZDF+ZFCmyOG2Ay2/9U1BhL182ap+wfRWf0YN
         dnHw==
X-Gm-Message-State: APjAAAVlsFy2cA5kc9afANbCYdzZTa6qHXLoUt54Cs2m/A2D/9t2qZfH
        oP6jKHfY2lSm491B4ZxpI83c5V3s7sm2QeTY0aWFK3th
X-Google-Smtp-Source: APXvYqw16sm7rA8e7wEAJ2AgHSdM+1PIcP4wLLOosNYiE+F+eDFm1M3VYa35VVG8spuLet7RBGRYMe2j6z1qZI0vpnU=
X-Received: by 2002:ab0:285a:: with SMTP id c26mr13204346uaq.81.1575656969740;
 Fri, 06 Dec 2019 10:29:29 -0800 (PST)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 6 Dec 2019 13:29:18 -0500
Message-ID: <CAN-5tyHJg4C5j72_CrCJhZ8hyzDe71Q9zw1USgmyxePg+3juZw@mail.gmail.com>
Subject: gssd question/patch
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Steve,

Question: Is this an interesting failure scenario (bug) that should be
fixed: client did a mount which acquired gss creds and stored in the
credential cache. Then say it umounts at some point. Then for some
reason the Kerberos cache is deleted (rm -f /tmp/krb5cc*). Now client
mounts again. This currently fails. Because gssd uses internal cache
to store creds lifetimes and thinks that tgt is still valid but then
trying to acquire a service ticket it fails (since there is no tgt).

Here's my proposed fix (I can send as a patch if this agreed upon).

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 0474783..3678524 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -121,6 +121,9 @@
 #include <krb5.h>
 #include <rpc/auth_gss.h>

+#include <sys/types.h>
+#include <fcntl.h>
+
 #include "nfslib.h"
 #include "gssd.h"
 #include "err_util.h"
@@ -314,6 +317,25 @@ gssd_find_existing_krb5_ccache(uid_t uid, char *dirname,
        return err;
 }

+/* check if the ticket cache exists, if not set nocache=1 so that new
+ * tgt is gotten
+ */
+static int
+gssd_check_if_cc_exists(struct gssd_k5_kt_princ *ple)
+{
+       int fd;
+       char cc_name[BUFSIZ];
+
+       snprintf(cc_name, sizeof(cc_name), "%s/%s%s_%s",
+               ccachesearch[0], GSSD_DEFAULT_CRED_PREFIX,
+               GSSD_DEFAULT_MACHINE_CRED_SUFFIX, ple->realm);
+       fd = open(cc_name, O_RDONLY);
+       if (fd < 0)
+               return 1;
+       close(fd);
+       return 0;
+}
+
 /*
  * Obtain credentials via a key in the keytab given
  * a keytab handle and a gssd_k5_kt_princ structure.
@@ -348,6 +370,8 @@ gssd_get_single_krb5_cred(krb5_context context,

        memset(&my_creds, 0, sizeof(my_creds));

+       if (!nocache && !use_memcache)
+               nocache = gssd_check_if_cc_exists(ple);
        /*
         * Workaround for clock skew among NFS server, NFS client and KDC
         * 300 because clock skew must be within 300sec for kerberos
