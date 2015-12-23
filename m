Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33968 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933346AbbLWR7m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2015 12:59:42 -0500
Received: by mail-pf0-f173.google.com with SMTP id e65so3318958pfe.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Dec 2015 09:59:42 -0800 (PST)
Date: Wed, 23 Dec 2015 09:59:49 -0800
From: Stephen Hemminger <stephen@networkplumber.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Fw: [Bug 109781] New: NFS fails mount from fstab
Message-ID: <20151223095949.6ad594a9@xeon-e3>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All network related bugs get assigned first to me, but this looks like NFS issue

Begin forwarded message:

Date: Tue, 22 Dec 2015 15:46:25 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 109781] New: NFS fails mount from fstab


https://bugzilla.kernel.org/show_bug.cgi?id=109781

            Bug ID: 109781
           Summary: NFS fails mount from fstab
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2.7
          Hardware: All
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: mkb@cydyreal.com
        Regression: No

Created attachment 198001
  --> https://bugzilla.kernel.org/attachment.cgi?id=198001&action=edit
grep -i nfs /var/log/messages*; [ and deleted extraneous stuff. ]

I can manual mount an NFS export from another identical machine, and mounting
at boot time from fstab worked under FC22.  Under FC23 I can still mount NFS by
hand but it fails to mount at boot time from fstab.  The fstab's are identical.
 I used dnf-system-upgrade on the NFS server to upgrade from FC21.  This worked
properly and I was able to boot my (old) FC22 client with NFS mount at boot.  I
installed a new SSD and installed FC23 from the live DVD image on the client,
and restored all the user and system config files from a backup tar (on the
client).  Now boot-time NFS mount fails.

I still habe the old hard drive with the FC22 image that can be booted and will
do the NFS boot-time mount (it is on an external USB3 drive) so we can
experiment with that if necessary, but I run processes 24/7 during the week, so
any experimentation would need to be done on weekends when I have down time.

dmesg produced no NFS messages.  Attached is a grep -i of NFS from
/var/log/messages*;.

-- 
You are receiving this mail because:
You are the assignee for the bug.
