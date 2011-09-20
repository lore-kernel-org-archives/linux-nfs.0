Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ironboy.h-da.de ([141.100.10.230]:28469 "EHLO ironboy.h-da.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751010Ab1ITSOO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 14:14:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.fbihome.de (Postfix) with ESMTP id F3EE6932BE
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 20:14:15 +0200 (CEST)
Received: from mail.fbihome.de ([127.0.0.1])
	by localhost (stud1 [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
	id 17257-19 for <linux-nfs@vger.kernel.org>;
	Tue, 20 Sep 2011 20:14:15 +0200 (CEST)
Received: from users.fbihome.de (unknown [141.100.40.82])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.fbihome.de (Postfix) with ESMTP id D62F2932BD
	for <linux-nfs@vger.kernel.org>; Tue, 20 Sep 2011 20:14:15 +0200 (CEST)
Date: Tue, 20 Sep 2011 20:14:12 +0200 (CEST)
From: Jan-Marek Glogowski <glogow@fbihome.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] idmapd: Fix decoding of octal encoded fields.
Message-ID: <alpine.DEB.2.02.1109201952540.26882@users.fbihome.de>
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The decoded octal will always be positive and (char) -1 is negative. Any 
field containing an encoded octal will be rejected.

As the encoded value should be an unsigned char, fix the check to reject 
all values > (unsigned char) -1 = UCHAR_MAX, as this indicate an error in 
the encoding.

Signed-off-by: Jan-Marek Glogowski <glogow@fbihome.de>

--- nfs-utils-1.2.4.orig/utils/idmapd/idmapd.c
+++ nfs-utils-1.2.4/utils/idmapd/idmapd.c
@@ -925,9 +925,9 @@ getfield(char **bpp, char *fld, size_t f
  		if (*bp == '\\') {
  			if ((n = sscanf(bp, "\\%03o", &val)) != 1)
  				return (-1);
-			if (val > (char)-1)
+			if (val > UCHAR_MAX)
  				return (-1);
-			*fld++ = (char)val;
+			*fld++ = val;
  			bp += 4;
  		} else {
  			*fld++ = *bp;
