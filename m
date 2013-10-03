Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:22103 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814Ab3JCQYN convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 12:24:13 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: fedfs-utils 0.9.3 packaged in EPEL for RHEL 6
From: Chuck Lever <chuck.lever@oracle.com>
Date: Thu, 3 Oct 2013 12:24:07 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "autofs@vger.kernel.org" <autofs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>
Message-Id: <48AA1466-A323-4A23-ACFB-66EB121BEFB8@oracle.com>
To: "fedfs-utils;release announcements"
	<fedfs-utils-announce@oss.oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are very pleased to announce the first release of fedfs-utils for RHEL 6, available in the Extra Packages for Enterprise Linux (EPEL) repository.

The fedfs-utils package contains an implementation of the Federated Filesystem (FedFS) Proposed Standard for Linux.  For an introduction to FedFS, see RFC 5716.

This is an ALPHA quality release.  The code in this release is not guaranteed to work. Programming, administrative, and user interfaces may change significantly before the next release.  This release is for technology preview only.


This first release is comprised only of the fedfs-utils-client and fedfs-utils-common packages.  The client-side fedfs-utils components can be used in any FedFS-standards compliant domain, including a domain created with the fedfs-utils server components currently packaged in Fedora 18 and later.

The fedfs-utils server and admin components may be released for RHEL 6/EPEL at a later date.  Watch this space.


To install fedfs-utils on EL6 systems:

 1. Enable the EPEL repo

 2. "sudo yum install fedfs-utils-client"

 3. Add the line "/nfs4	/usr/sbin/fedfs-map-nfs4" to /etc/auto.master

 4. "sudo service autofs restart"

FedFS relies on NFS referral support built into the Linux NFS client.  Be sure the kernel on your NFS clients is up to date.


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

