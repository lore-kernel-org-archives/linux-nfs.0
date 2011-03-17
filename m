Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:54577 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757443Ab1CQB2F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 21:28:05 -0400
Received: by qyk7 with SMTP id 7so3965167qyk.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2011 18:28:04 -0700 (PDT)
Date: Wed, 16 Mar 2011 21:28:04 -0400
Message-ID: <AANLkTik72b2H3yVx7-YcE1Bmp73LboMzZ+DSOjww=RS0@mail.gmail.com>
Subject: libgssglue-0.2
From: Kevin Coffman <kwc@citi.umich.edu>
To: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A new version of library libgssglue is now available from:

http://www.citi.umich.edu/projects/nfsv4/linux/libgssglue/libgssglue-0.2.tar.gz

Changes since libgssglue-0.1:

	* Modify the gss_acquire_cred() code to accept, and
	  properly handle, an input name of GSS_C_NO_NAME.
	  Other misc. changes to support this change.
	* Remove some generated files from git.  Change
	  autogen.sh to clean up files that might become
	  outdated and incompatible.
