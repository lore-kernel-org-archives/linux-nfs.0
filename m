Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51330 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927Ab0GAJoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 05:44:06 -0400
Received: by iwn7 with SMTP id 7so1850403iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jul 2010 02:44:01 -0700 (PDT)
Message-ID: <4C2C635D.9000906@gmail.com>
Date: Thu, 01 Jul 2010 05:43:57 -0400
From: Doug Nazar <nazard.lkml@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Fix memcmp result comparison error for uuid match.
Content-Type: multipart/mixed;
 boundary="------------000101050702090101010202"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------000101050702090101010202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

  Small typo in the new fs uuid comparison code.


--------------000101050702090101010202
Content-Type: text/plain;
 name="nfs-utils-fsuuid-memcmp.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-utils-fsuuid-memcmp.diff"

commit 361f6d6c5da3c5c5ba709f8f3704865b0f7267cc
Author: Doug Nazar <nazard.michi@gmail.com>
Date:   Thu Jul 1 05:37:23 2010 -0400

    Fix memcmp result comparison error for uuid match.

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9e1b164..bf18a9a 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -513,7 +513,7 @@ void nfsd_fh(FILE *f)
 					for (type = 0;
 					     uuid_by_path(path, type, uuidlen, u);
 					     type++)
-						if (memcmp(u, fhuuid, uuidlen) != 0)
+						if (memcmp(u, fhuuid, uuidlen) == 0)
 							break;
 
 				if (memcmp(u, fhuuid, uuidlen) != 0)

--------------000101050702090101010202--
