Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46912 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab1AETtH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 14:49:07 -0500
Message-ID: <4D24CB2E.5030207@netapp.com>
Date: Wed, 05 Jan 2011 14:49:02 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v2 0/5] Add secinfo to the NFS client
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These patches will add the secinfo procedure to the NFS client 
and do some cleanup along the way.  The final result will should
be able to cross mountpoints using a different form of security
and auto-detect the security of an initial NFS v4 mount.

v2:
 - Add more details about the call_sync improvement
 - Don't initialize global constant function pointers to NULL

Bryan
