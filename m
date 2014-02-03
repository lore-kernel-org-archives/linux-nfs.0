Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45283 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbaBCRfC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 12:35:02 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Announcing the release of fedfs-utils version 0.10.0
From: Chuck Lever <chuck.lever@oracle.com>
Date: Mon, 3 Feb 2014 12:34:35 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        samba-technical@lists.samba.org, autofs@vger.kernel.org
Message-Id: <99CE2C34-8A84-4BE0-A03D-40DA4D7E9903@oracle.com>
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This package contains an implementation of the Federated Filesystem (FedFS) Proposed Standard for Linux.  For an introduction to FedFS, see RFC 5716.

This is an ALPHA quality release.  The code in this release is not guaranteed to work.  Programming, administrative, and user interfaces may change significantly before the next release.  This release is for technology preview only.

Non-backwards compatible changes:
	• *ldaperr removed from libnsdb API
	• ADMIN client tools no longer use AUTH_NONE security
	• ADMIN client tools no longer exit with FedFS status code

New features:
	• Python package PyFedfs added
	• Tool for configuring FedFS domain root directories
	• Tool for setting up NSDBs using OpenLDAP
	• Simpler NCE discovery (compliant with new FedFS NCE I-D)
	• admin_t API for performing remote ADMIN requests
	• rpc.fedfsd uses an ACL to control who can perform ADMIN requests
	• rpc.fedfsd and ADMIN tools support RPCSEC and Kerberos v5
    
Minor fixes:
	• FEDFS_LOOKUP_JUNCTION no longer returns NSDB_LDAP_VAL
	• fedfs-map-nfs4 handles multiple SRV records
	• Packaging simplifications
	• Dozens of code clean-ups and bug fixes; consult Changelog for details


Going forward, stable patches now go into “master,” rather than a separate branch.  Development for fedfs-utils 0.11 will be moved to a topic branch.

fedfs-utils 0.9 is packaged for EPEL 6 and will continue to see bug fixes.


Tarball releases available at:
  http://git.linux-nfs.org/?p=cel/fedfs-releases.git;a=summary

Git repository available at:
  http://git.linux-nfs.org/?p=cel/fedfs-utils.git;a=shortlog;h=refs/heads/master

Patchwork available at:
  http://patchwork.ozlabs.org/project/fedfs-utils/list/

--
Chuck Lever

