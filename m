Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:36980 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754348Ab2LGXqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 18:46:16 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Fri, 7 Dec 2012 18:46:15 -0500
In-Reply-To: <OF13B342CA.3B3F39AC-ON88257ACD.0080BC4F-88257ACD.00815AED@LocalDomain>
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@LocalDomain> <OF13B342CA.3B3F39AC-ON88257ACD.0080BC4F-88257ACD.00815AED@LocalDomain>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org
MIME-Version: 1.0
Subject: Re: notify_deviceid_type4
Message-ID: <OFB389C816.CDC36461-ON88257ACD.0082322A-88257ACD.0082922C@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Fri, 7 Dec 2012 15:46:11 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, can you please apply the following patch so we are in compliance 
with the spec.
Thanks, Marc.

diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 59cc833..ad32df5 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -499,8 +499,8 @@ enum pnfs_iomode {
 };
 
 enum pnfs_notify_deviceid_type4 {
-       NOTIFY_DEVICEID4_CHANGE = 1 << 1,
-       NOTIFY_DEVICEID4_DELETE = 1 << 2,
+       NOTIFY_DEVICEID4_CHANGE = 1,
+       NOTIFY_DEVICEID4_DELETE = 2,
 };
 
 #define NFL4_UFLG_MASK                 0x0000003F

-------------------------------------------------------------------------------------------------------------

The spec defines notify_deviceid_type4 as:

20.12.1.  ARGUMENT
   /*
    * Device notification types.
    */
   enum notify_deviceid_type4 {
           NOTIFY_DEVICEID4_CHANGE = 1,
           NOTIFY_DEVICEID4_DELETE = 2
   };

