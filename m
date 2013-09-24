Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41476 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab3IXNAZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Sep 2013 09:00:25 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: fedfs-utils 0.9.3 packaged in Fedora
Date: Tue, 24 Sep 2013 09:00:00 -0400
Message-Id: <B94A9B58-EA2D-4566-A3B5-EAC15F428E9A@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "autofs@vger.kernel.org" <autofs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The latest upstream release of fedfs-utils (0.9.3) is now available in Fedora 18, 19, 20, and rawhide.  This update replaces the previous version of the package (0.9.2).

The fedfs-utils package contains an implementation of the Federated Filesystem (FedFS) Proposed Standard for Linux.  For an introduction to FedFS, see RFC 5716.

This is an ALPHA quality release.  The code in this release is not guaranteed to work. Programming, administrative, and user interfaces may change significantly before the next release.  This release is for technology preview only.

Changes since 0.9.2:
	• Allow fedfs-utils to build on systems that do not have liburiparser

Changes since 0.9.1:
	• Packaging-related improvements

Changes since 0.9.0:
	• Address build issues with recent automake and libtools
	• Replace nl_langinfo(CODESET) check in command line tools

New with fedfs-utils 0.9.0:
	• NSDB schema complies with latest draft standard
	• DNS SRV support complies with RFC 6641
	• NSDB clients support the FEDFS_SEC_TLS security type
	• NSDB clients can follow LDAP referrals returned by NSDB nodes
	• New tools for configuration of NSDBs
	• New "display-junction" debugging command

Project web site
http://wiki.linux-nfs.org/wiki/index.php/FedFsUtilsProject

Installation guide:
http://wiki.linux-nfs.org/wiki/index.php/FedFsInstallationGuide0.9

Tarball releases available at
http://git.linux-nfs.org/?p=cel/fedfs-releases.git;a=summary

Git repository available at
http://git.linux-nfs.org/?p=cel/fedfs-utils.git;a=shortlog;h=refs/heads/0.9-stable

Patchwork available at
http://patchwork.ozlabs.org/project/fedfs-utils/list/