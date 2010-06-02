Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932805Ab0FBVOG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 17:14:06 -0400
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o52LE4Ja013146
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 2 Jun 2010 17:14:04 -0400
Received: from badhat.bos.devel.redhat.com (vpn-227-128.phx2.redhat.com [10.3.227.128])
	by int-mx04.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o52LE4uJ013337
	for <linux-nfs@vger.kernel.org>; Wed, 2 Jun 2010 17:14:04 -0400
Message-ID: <4C06C99B.2070004@RedHat.com>
Date: Wed, 02 Jun 2010 17:14:03 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rpc.mountd: Turn off root_squash on pseudo roots, its not
 needed.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

It turns out the setting of NFSEXP_ROOTSQUASH option
on pseudo roots breaks v4 exports when the no_root_squash
is set on the 'real' export. For example,

The export:

    /home/user/dir  *(rw,no_root_squash)

the /home/user directory has the 0700 permission modes

Now from an v4 enabled client do the following mount
will fail with permission denied. 
   mount server:/home/user/dir /mnt

The reason being, the 'no_root_squash' option is only
being applied to the 'dir' part of the path. So then
root tries to lookup the 'user' part, its denied. 

Now turns out the NFSEXP_ROOTSQUASH option is not need
to be set on pseudo roots because one, they are marked
as read only and two only the export part of the path 
are exposed if by chance the actual pseudo root is 
mounted. For example:
    # mount server:/ /mnt
    # ls /mnt
     ./  ../  home/
    # ls /mnt/home
    ./  ../  user/

only the above directories would be shown and they would be 
read-only

steved.


Currently the default setting of a pseudo root is to have
NFSEXP_ROOTSQUASH enabled. This setting will cause the looking
up of real export to fail when have the no_root_squash set.

It turns the setting of NFSEXP_ROOTSQUASH is not needed on pseudo
roots for two reasons. 1) pseudo roots are marked as read-only so
they can not be written on. 2) pseudo roots only show exported
entries when they are mounted.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/v4root.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 7fd6af3..41b77eb 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -35,9 +35,8 @@ static nfs_export pseudo_root = {
 	.m_export = {
 		.e_hostname = "*",
 		.e_path = "/",
-		.e_flags = NFSEXP_READONLY | NFSEXP_ROOTSQUASH
-				| NFSEXP_NOSUBTREECHECK | NFSEXP_FSID
-				| NFSEXP_V4ROOT,
+		.e_flags = NFSEXP_READONLY | NFSEXP_NOSUBTREECHECK | 
+				NFSEXP_FSID | NFSEXP_V4ROOT,
 		.e_anonuid = 65534,
 		.e_anongid = 65534,
 		.e_squids = NULL,


