Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932271AbaKERBQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 12:01:16 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1GWl022058
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA5H1Gjd030330
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:16 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sA5H1Ft2000939
	for <linux-nfs@vger.kernel.org>; Wed, 5 Nov 2014 12:01:15 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sA5H1FEe000938
	for linux-nfs@vger.kernel.org; Wed, 5 Nov 2014 12:01:15 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils RFC PATCH 10/15] mountstats: Fix IndexError in __parse_nfs_line
Date: Wed,  5 Nov 2014 12:01:07 -0500
Message-Id: <1415206872-864-11-git-send-email-smayhew@redhat.com>
In-Reply-To: <1415206872-864-1-git-send-email-smayhew@redhat.com>
References: <1415206872-864-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If __parse_nfs_line is is called on a line that has 'fstype nfsd', it'll
raise an IndexError trying to parse a nonexistent statvers entry.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index b3231b2..77975ad 100755
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -215,13 +215,13 @@ class DeviceData:
             self.__nfs_data['export'] = words[1]
             self.__nfs_data['mountpoint'] = words[4]
             self.__nfs_data['fstype'] = words[7]
-            if words[7].find('nfs') != -1:
+            if words[7].find('nfs') != -1 and words[7] != 'nfsd':
                 self.__nfs_data['statvers'] = words[8]
         elif 'nfs' in words or 'nfs4' in words:
             self.__nfs_data['export'] = words[0]
             self.__nfs_data['mountpoint'] = words[3]
             self.__nfs_data['fstype'] = words[6]
-            if words[6].find('nfs') != -1:
+            if words[6].find('nfs') != -1 and words[6] != 'nfsd':
                 self.__nfs_data['statvers'] = words[7]
         elif words[0] == 'age:':
             self.__nfs_data['age'] = int(words[1])
-- 
1.9.3

