Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:58345 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab2LAFzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 1 Dec 2012 00:55:02 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sat, 1 Dec 2012 00:55:01 -0500
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: notify_deviceid_type4
Message-ID: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@us.ibm.com>
From: Marc Eshel <eshel@us.ibm.com>
Date: Fri, 30 Nov 2012 21:54:55 -0800
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec defines notify_deviceid_type4 as:

20.12.1.  ARGUMENT
   /*
    * Device notification types.
    */
   enum notify_deviceid_type4 {
           NOTIFY_DEVICEID4_CHANGE = 1,
           NOTIFY_DEVICEID4_DELETE = 2
   };


but the Linux code in nfs4.h has, is that going to be fixed?

enum pnfs_notify_deviceid_type4 {
        NOTIFY_DEVICEID4_CHANGE = 1 << 1,
        NOTIFY_DEVICEID4_DELETE = 1 << 2,
};

