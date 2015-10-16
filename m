Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:60730 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751589AbbJPUoz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Oct 2015 16:44:55 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: <linux-nfs@vger.kernel.org>
Cc: "Bruce Fields" <bfields@fieldses.org>
Subject: Pull request for pynfs
Date: Fri, 16 Oct 2015 13:44:42 -0700
Message-ID: <012101d10853$7cae4ac0$760ae040$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Please pull the top patch from:

https://github.com/ffilz/pynfs/commits/master

It fixes CID2 to allow NFS4_OK when SETCLIENTID with a different principal
replaces a clientid that has no state, and adds CID2a which expects
NFS4ERR_CLID_INUSE since it does have state.

Thanks

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

