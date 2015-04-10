Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbbDJWA5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Apr 2015 18:00:57 -0400
From: Zach Brown <zab@redhat.com>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org
Subject: [PATCH RFC 0/3] simple copy offloading system call
Date: Fri, 10 Apr 2015 15:00:33 -0700
Message-Id: <1428703236-24735-1-git-send-email-zab@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everyone!

Here's my current attempt at the most basic system call interface for
offloading copying between files.  The system call and vfs function
are relatively light wrappers around the file_operation method that
does the heavy lifting.

There was interest at LSF in getting the basic infrastructure merged
before worrying about adding behavioural flags and more complicated
implementations.  This series only offers a refactoring of the btrfs
clone ioctl as an example of an implementation of the file
copy_file_range method.

I've added support for copy_file_range() to xfs_io in xfsprogs and
have the start of an xfstest that tests the system call.  I'll send
those to fstests@.

So how does this look?

Do we want to merge this and let the NFS and block XCOPY patches add
their changes when they're ready?

- z

