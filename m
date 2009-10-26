From: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>
Subject: [RFC][PATCH] relax insecure option on mountd
Date: Mon, 26 Oct 2009 15:56:27 -0500
Message-ID: <3C8019BD-4231-428F-B94C-5257111F9E96@openrbg.com>
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:53168 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751040AbZJZU4d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Oct 2009 16:56:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nfs-utils 1.2.0, I noticed that the insecure option validates that  
the client port is a
subset of IPPORT_RESERVED as opposed to just validating it is a valid
reserved port. The following proposed patch would correct that issue.

Signed-off-by: Robert Gordon <rbg-dkEPNP4dzOJBDgjK7y7TUQ@public.gmane.org>

--- ./utils/mountd/auth.c.orig
+++ ./utils/mountd/auth.c
@@ -169,7 +169,6 @@ auth_authenticate_internal(char *what, s
  		}
  	}
  	if (!(exp->m_export.e_flags & NFSEXP_INSECURE_PORT) &&
-		    (ntohs(caller->sin_port) <  IPPORT_RESERVED/2 ||
  		     ntohs(caller->sin_port) >= IPPORT_RESERVED)) {
  		*error = illegal_port;
  		return NULL;

