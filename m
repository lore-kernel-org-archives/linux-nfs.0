Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14854 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751802Ab3JUUID convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 16:08:03 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Strange cred expiry behavior
Date: Mon, 21 Oct 2013 20:07:44 +0000
Message-ID: <85F2BCBA-9565-497F-BFF4-FEB29301D655@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I saw this issue when revived my branch for using SP4_MACH_CRED only in the error (EKEYEXPIRED) path, and was able to reproduce it on Trond's testing branch, so this behavior is definitely new.  The client is running F19 updated pretty recently (nfs-utils 1.2.8-4.0.fc19).

The issue:

  - mount a kerberos export

  - kinit with a really short lifetime: "kinit -l 1m"

  - run something (like dd) that will hold a file open and write to it for more than the lifetime of the kinit

! - after the credential expire, the number of keys listed in "klist" starts to grow. Notice how the "Valid starting" time is after the "Expires" time.  The list seems to grow forever - my test program writes 4k every second and the list seemed to grow by 1 line per second.  Example klist output:


Ticket cache: DIR::/run/user/1749600001/krb5cc/tktYmpGlX
Default principal: dros@APIKIA.FAKE

Valid starting       Expires              Service principal
10/21/2013 15:39:38  10/21/2013 15:40:35  krbtgt/APIKIA.FAKE@APIKIA.FAKE
10/21/2013 15:39:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:35  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:36  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:37  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:38  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:39  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:40  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:41  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE
10/21/2013 15:40:42  10/21/2013 15:40:35  nfs/zero.apikia.fake@APIKIA.FAKE

This seems like a gssd bug in handling cred refresh upcalls. I'll debug further and hopefully find a fix.

Has anyone seen this issue before or have any thoughts on recent changes that could cause this? I definitely didn't see this a little more than a month ago when I started testing cred expiry...

-dros