Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab3LPDTI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Dec 2013 22:19:08 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBG3J8AT005603
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 22:19:08 -0500
Received: from tasleson.csb (vpn-61-38.rdu2.redhat.com [10.10.61.38])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rBG3J7Ml007231
	for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 22:19:07 -0500
Message-ID: <52AE712B.3060404@redhat.com>
Date: Sun, 15 Dec 2013 21:19:07 -0600
From: Tony Asleson <tasleson@redhat.com>
Reply-To: tasleson@redhat.com
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: exportfs: Messages indicating unsupported operation that works
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I try to export a directory that has a space in it I get the following:

# exportfs *:"/mnt/has space"
exportfs: /mnt/has space does not support NFS export

exit code is 0.

If I do:

# exportfs -v
/mnt/has space	<world>(ro,wdelay,root_squash,no_subtree_check,
sec=sys,ro,secure,root_squash,no_all_squash)

It exists and I can mount it from a client and everything appears fine.

I took a peek at the code and we are failing in test_export.  We are
getting a -1 returned when we write to: /proc/net/rpc/nfsd.export/channel .

This seems like a confusing message when it appears that everything is
working, thoughts?

Notes:
- Kernel Linux rawhide 3.13.0-0.rc3.git1.2.fc21.x86_64
- nfs-utils: Latest from git, but this happens on older released
versions tested too.

Thanks,
Tony
