Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3847 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751988Ab1AFV6l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Jan 2011 16:58:41 -0500
Message-ID: <4D263B0E.4060905@netapp.com>
Date: Thu, 06 Jan 2011 16:58:38 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH v3 0/5] Add secinfo t othe NFS client
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

These patches will add the secinfo procedure to the NFS client 
and do some cleanup along the way.  The final result will should
be able to cross mountpoints using a different form of security
and auto-detect the security of an initial NFS v4 mount.

v3:
 - Check for server returning too many security flavors
 - Check for gss_oid_len > max_gss_oid_len
 - New functions in namespace.c should be static

v2:
 - Add more details about the call_sync improvement
 - Don't initialize global constant function pointers to NULL

Bryan
