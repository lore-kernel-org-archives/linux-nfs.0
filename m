Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32143 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932487AbcDYSmL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 14:42:11 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=utf-8
Subject: Annoucing the release of fedfs-utils version 0.10.6
Date: Mon, 25 Apr 2016 14:41:51 -0400
Message-Id: <BA325E78-BE55-455F-A22C-474360322C1D@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        samba-technical@lists.samba.org, autofs@vger.kernel.org
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This package contains an implementation of the Federated Filesystem
(FedFS) Proposed Standard for Linux. For an introduction to FedFS, see
RFC 5716.

This is an ALPHA quality release.  The code in this release is not
guaranteed to work.  Programming, administrative, and user interfaces
may change significantly before the next release.  This release is for
technology preview only.


Changes since 0.10.5:
	• Fix compatibility issues with newer glibc/libtirpc releases


Changes since 0.10.4:
	• More fixes in admin tools


Changes since 0.10.3:
	• Fix bugs in admin tools


Changes since 0.10.2:
	• More error handling fixes
	• Remove an incorrect package dependency


Changes since 0.10.1:
	• Fix bugs in nsdb-jumpstart
	• Numerous fixes to error handling paths
	• Introduce basic support for Coverity analysis


Changes since 0.10.0:
	• Address packaging issues


New with fedfs-utils 0.10.0:

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


Source code available at:
http://git.linux-nfs.org/?p=cel/fedfs-utils.git

The new head of the master branch is commit:

448da0508a10 Release 0.10.6

Patchwork available at:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

Tarball releases available at:
http://git.linux-nfs.org/?p=cel/fedfs-releases.git;a=summary

--
Chuck Lever



