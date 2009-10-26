From: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC][PATCH] relax insecure option on mountd (ver 2)
Date: Mon, 26 Oct 2009 16:40:59 -0500
Message-ID: <DE1C4ECC-6D4A-4EA6-A4FB-BE76E31C4A40@openrbg.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:65074 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbZJZVlF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2009 17:41:05 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs-utils 1.2.0, I noticed that the insecure option validates that  
the client port is a
subset of IPPORT_RESERVED as opposed to just validating it is a valid
reserved port. The following proposed patch would correct that issue.

Signed-off-by: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>

--- ./utils/mountd/auth.c.orig
+++ ./utils/mountd/auth.c
@@ -169,8 +169,7 @@ auth_authenticate_internal(char *what, s
  		}
  	}
  	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
-		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
-		     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
+		     ntohs(caller->sin_port) >= IPPORT_RESERVED) {
  		*error = illegal_port;
  		return NULL;
  	}

