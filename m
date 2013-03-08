Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:39021 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab3CHTrH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:47:07 -0500
Received: by mail-ie0-f173.google.com with SMTP id 9so2553307iec.4
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:47:07 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] gssd: Update description of "-l" option
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:47:05 -0500
Message-ID: <20130308194705.5656.38099.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move most of the text in the description of the "-l" option up to
the DESCRIPTION section, to match what was done for "-n" and "-k".

The discussion is then less restricted by formatting, and we can
take the space to introduce a few concepts before describing the
behavior of rpc.gssd.

Fix a few misspellings and grammar issues while here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.c   |    2 +-
 utils/gssd/gssd.man |   47 ++++++++++++++++++++++++++---------------------
 2 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index a3292c9..0be2517 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -147,7 +147,7 @@ main(int argc, char *argv[])
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 				limit_to_legacy_enctypes = 1;
 #else 
-				errx(1, "Setting encryption type not support by Kerberos libraries.");
+				errx(1, "Encryption type limits not supported by Kerberos libraries.");
 #endif
 				break;
 			default:
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 1d6fb4c..79d9bf9 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -172,6 +172,27 @@ If
 .B rpc.gssd
 cannot obtain a machine credential (say, the local system has
 no keytab), NFSv4 operations that require machine credentials will fail.
+.SS Encryption types
+A realm administrator can choose to add keys encoded in a number of different
+encryption types to the local system's keytab.
+For instance, a host/ principal might have keys for the
+.BR aes256-cts-hmac-sha1-96 ,
+.BR aes128-cts-hmac-sha1-96 ,
+.BR des3-cbc-sha1 ", and"
+.BR arcfour-hmac " encryption types."
+This permits
+.B rpc.gssd
+to choose an appropriate encryption type that the target NFS server
+supports.
+.P
+These encryption types are stronger than legacy single-DES encryption types.
+To interoperate in environments where servers support
+only weak encryption types,
+you can restrict your client to use only single-DES encryption types
+by specifying the
+.B -l
+option when starting
+.BR rpc.gssd .
 .SH OPTIONS
 .TP
 .B -f
@@ -193,28 +214,12 @@ The default value is
 .IR /etc/krb5.keytab .
 .TP
 .B -l
-Tells
+When specified, restricts
 .B rpc.gssd
-to limit session keys to Single DES even if the kernel supports stronger
-encryption types. Service ticket encryption is still governed by what
-the KDC believes the target server supports. This way the client can
-access a server that has strong keys in its keytab for ticket decryption
-but whose kernel only supports Single DES.
-.IP
-The alternative is to put only Single DES keys in the server's keytab
-and limit encryption types for its principal to Single DES on the KDC
-which will cause service tickets for this server to be encrypted using
-only Single DES and (as a side-effect) contain only Single DES session
-keys.
-.IP
-This legacy behaviour is only required for older servers
-(pre nfs-utils-1.2.4). If the server has a recent kernel, Kerberos
-implementation and nfs-utils it will work just fine with stronger
-encryption.
-.IP
-.B Note:
-This option is only available with Kerberos libraries that 
-support setable encryption types.
+to sessions to weak encryption types such as
+.BR des-cbc-crc .
+This option is available only when the local system's Kerberos library
+supports settable encryption types.
 .TP
 .BI "-p " path
 Tells

