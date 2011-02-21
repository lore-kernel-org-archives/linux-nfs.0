Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47415 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab1BUWlY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:41:24 -0500
Message-ID: <4D62EA13.1000809@panasas.com>
Date: Mon, 21 Feb 2011 14:41:23 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: linux-pnfs-cthon git tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've set up a git tree for Connectathon to hold up the fixes we're testing
here temporarily.  I'll update the main tree when we're done so not to cause
unnecessary churn.

The following branches have been posted up:

  pnfs-all-2.6.37
  pnfs-all-latest 	# based on v2.6.38-rc5
  pnfs-submit-wave3	# based on v2.6.38-rc5 .. Andy's wave3-rev11 .. Fred's 2 SQUASHMEs
  pnfs-submit-wave4	# based on pnfs-submit-wave3 and Fred's wave4 patches

The -all branches include the fixes for layout recall that I've posted on the mailing list.

Benny
