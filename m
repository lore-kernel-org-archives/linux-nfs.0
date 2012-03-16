Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:57915 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416Ab2CPGRP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 02:17:15 -0400
Message-ID: <4F62DADD.3010502@panasas.com>
Date: Thu, 15 Mar 2012 23:17:01 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@tonian.com>, Steve Dickson <steved@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>
CC: "Welch, Brent" <welch@panasas.com>
Subject: [PATCHSET 0/4] Auto-login support for the pnfs-objects protocol
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I'm happy to submit the auto-login support to pnfs-objects protocol.
Please see individual patches for explanations.

It was heavily tested and performs very well.

Submitted, as usual, a patch to pnfsd-exofs that enables this in the pnfs Server
Then follows a modest patch to the pnfs-obj client layout-driver.
And last a patch to the nfs-utils package with a script that executes the
login.

We currently only support the iscsi://ip_addr:ip_port URI protocol.
But other are easy to add by modifying the script, as the Kernel part
is just a transparent pass through between the Server and the osd_login
script.

Benny: As the editor of the STD please review and confirm

List of Patches:
[PATCH 1/4] pnfsd-exofs:  Add autologin support to exofs
	
	This patch is for Benny's pnfsd tree. Thanks

[PATCH 2/4] pnfs-obj: Remove unused variable from objlayout_get_deviceinfo().

	Trond: This is not important just something found when coding.
	
[PATCH 3/4] pnfs-obj: autologin: Add support for protocol autologin

	Trond: If at all possible to make the merge window with this one
	It would be great. Thanks.

[PATCH 4/4] osd_login: Add autologin script for objlayoutdriver.

	Steve D: This patch is for you. Thanks a million man, it
	made the complete code Kernel and user-mode 1/7 the size
	Cheers

Thanks
Sachin & Boaz
