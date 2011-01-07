Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42012 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751910Ab1AGSwO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Jan 2011 13:52:14 -0500
Message-ID: <4D2760D4.1010308@netapp.com>
Date: Fri, 07 Jan 2011 13:52:04 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v4 0/5] Add secinfo to the NFS client
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


These patches will add the secinfo procedure to the NFS client 
and do some cleanup along the way.  The final result will should
be able to cross mountpoints using a different form of security
and auto-detect the security of an initial NFS v4 mount.

v4:
 - Properly set the number of security flavors decoded by the client
 - Return an int rather than an rpc_authflavor_t for better error checking
v3:
 - Check for server returning too many security flavors
 - Check for gss_oid_len > max_gss_oid_len
 - New functions in namespace.c should be static

v2:
 - Add more details about the call_sync improvement
 - Don't initialize global constant function pointers to NULL

Bryan
