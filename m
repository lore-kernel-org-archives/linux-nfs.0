Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:39206 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab3GBTNp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Jul 2013 15:13:45 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: [fedfs-utils ANNOUNCE] Announcing the release of fedfs-utils 0.9.2
Date: Tue, 2 Jul 2013 15:13:20 -0400
Message-Id: <17AC10A6-EDB2-4FD0-A0DB-A14FFC2B2BFE@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "autofs@vger.kernel.org" <autofs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This package contains an implementation of the Federated Filesystem (FedFS) Proposed Standard for Linux.  For an introduction to FedFS, see RFC 5716.

This is an ALPHA quality release.  The code in this release is not guaranteed to work.  Programming, administrative, and user interfaces may change significantly before the next release.  This release is for technology preview only.

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

Tarball releases:
http://git.linux-nfs.org/?p=cel/fedfs-releases.git;a=summary

Git repository:
http://git.linux-nfs.org/?p=cel/fedfs-utils.git;a=shortlog;h=refs/heads/0.9-stable

Patchwork:
http://patchwork.ozlabs.org/project/fedfs-utils/list/

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

