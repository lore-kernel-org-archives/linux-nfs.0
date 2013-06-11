Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:39709 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753238Ab3FKRjp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jun 2013 13:39:45 -0400
Message-ID: <51B75979.5070300@mindspring.com>
Date: Tue, 11 Jun 2013 10:08:09 -0700
From: Frank Filz <ffilz-lists@mindspring.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
CC: ffilz-lists@mindspring.com, ffilz@us.ibm.com
Subject: Some pynfs updates
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Please pull this branch from github: 
https://github.com/ffilz/pynfs/commits/master

The git log is below.

Thanks

Frank

commit 2ddd13347e2769801e1c72c8e8d32cef1bcb3fe0
Author: Frank S. Filz <ffilz@us.ibm.com>
Date:   Wed May 22 17:11:02 2013 -0700

Make LOOK10 accept MSG_ACCEPTED: GARBAGE_ARGS as well as NFS4ERR_BADXDR

The Ganesha server does XDR for the whole request before starting to
process COMPOUND. As a result, LOOK10 causes an XDR failure that Ganesha
responds at RPC layer and never gets to NFS layer to return NFS4ERR_BADXDR.

Signed-off-by: Frank S. Filz <ffilz@us.ibm.com>

commit 1eda552a5183e71351fc84c53b9561b8a9cab4f1
Author: Frank S. Filz <ffilz@us.ibm.com>
Date:   Wed May 1 16:14:41 2013 -0700

Make some tests runable by request

Ganesha can pass several tests that were made inoperable.
The original FLAGS: for these were commented out and FLAGS:
is left blank so these tests only run if requested for.

Plus a few tests had duplicate names.

Signed-off-by: Frank S. Filz <ffilz@us.ibm.com>

commit a6548ab80a68787dc3fcb5c8531d4d189d77c3a9
Author: Frank S. Filz <ffilz@us.ibm.com>
Date:   Wed May 1 16:06:56 2013 -0700

Make mode 000 tests expect NFS4_OK when run as root

They will warn if NFS4ERR_ACCESS is returned.

Signed-off-by: Frank S. Filz <ffilz@us.ibm.com>
