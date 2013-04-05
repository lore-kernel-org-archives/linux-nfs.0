Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2147 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162903Ab3DEWhQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 18:37:16 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libtirpc-devel@lists.sourceforge.net
Cc: Steve Dickson <steved@redhat.com>
Subject: [PATCH 0/2] libtirpc and nfs-utils fix for export lucid context
Date: Fri,  5 Apr 2013 18:37:03 -0400
Message-Id: <1365201425-21702-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following 2 patches go in tandem.
One is for libtirpc and the other for nfs-utils.

The standard gss_krb5_export_lucid_sec_context call actually deletes the gss context
after it has been exported, so these patches perform a complete hand over of the
context from libtirpc, so that the context handle can be nulled out in the
gss_krb5_export_lucid_sec_context and the code does not attempt to free it
twice and cause segmentation faults in the unlucky case.

Simo Sorce
