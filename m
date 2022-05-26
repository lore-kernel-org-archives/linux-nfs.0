Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FAE6C433F5
	for <linux-nfs@archiver.kernel.org>; Fri, 27 May 2022 05:27:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237156AbiE0F15 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 27 May 2022 01:27:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46614 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231840AbiE0F1z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 May 2022 01:27:55 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 00156EBAA5
        for <linux-nfs@vger.kernel.org>; Thu, 26 May 2022 22:27:54 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id AD06C21A17;
        Fri, 27 May 2022 05:27:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1653629273; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=k+VLs/ptLNRNc758ahB/bYDsXtivmnabg9305OYQntA=;
        b=RIf132LIcgdNvwJeF67kNBp2dQj+hxxz4CJ5CueU8YSWiZCxcb3SvfJMYrfDDMn41QA0wO
        YjdAg76CapngdYOrg7cD0EdeaZA+wvxyLeKNxcCWQWvBmNBTQmsLwTVY6W0YLWQhz0+eKn
        gO1xUwv7HnTNGzpo43R8d7jYF4lr09g=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1653629273;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=k+VLs/ptLNRNc758ahB/bYDsXtivmnabg9305OYQntA=;
        b=ifnZkK243Zmc2Vb6i46tezRkEZlisagGQdKrXP0/b+nv2kaEotoon5+zMi5/fHauUxTUBP
        UFLC4ExGYvrXnFDw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id DDB871346B;
        Fri, 27 May 2022 05:27:52 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id I/iSJlhhkGI4ewAAMHmgww
        (envelope-from <neilb@suse.de>); Fri, 27 May 2022 05:27:52 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     Steve Dickson <steved@redhat.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-reply-to: <165352672998.11129.5573262612495384287@noble.neil.brown.name>
References: <165352672998.11129.5573262612495384287@noble.neil.brown.name>
Subject: [PATCH nfs-utils] autoconf: change tirpc to check for a file, not for
 an include
Date:   Thu, 26 May 2022 10:59:58 +1000
Message-id: <165352679825.11129.7422243280120268766@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Recent autoconf don't like variables in AC_CHECK_INCLUDE so we get a
warning.
In libtirpc.m4 we only need to check for the existence of a file, we
don't need to extra  support for includes, such as defining HAVE_TIRPC_H
or whatever.

So change from AC_CHECK_INCLUDE to AC_CHECK_FILE.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 aclocal/libtirpc.m4 | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/aclocal/libtirpc.m4 b/aclocal/libtirpc.m4
index f7de5193c177..bddae0226931 100644
--- a/aclocal/libtirpc.m4
+++ b/aclocal/libtirpc.m4
@@ -49,9 +49,9 @@ AC_DEFUN([AC_LIBTIRPC_OLD], [
   dnl Also must have the headers installed where we expect
   dnl to look for headers; add -I compiler option if found
   AS_IF([test "$has_libtirpc" =3D "yes"],
-        [AC_CHECK_HEADERS([${tirpc_header_dir}/netconfig.h],
-                          [AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"]=
)],
-                          [has_libtirpc=3D"no"])])
+        [AC_CHECK_FILE([${tirpc_header_dir}/netconfig.h],
+                       [AC_SUBST([AM_CPPFLAGS], ["-I${tirpc_header_dir}"])],
+                       [has_libtirpc=3D"no"])])
=20
   dnl Now set $LIBTIRPC accordingly
   AS_IF([test "$has_libtirpc" =3D "yes"],
--=20
2.36.1

