Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbaKZTN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 14:13:57 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDvm1024972
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:57 -0500
Received: from tonberry.usersys.redhat.com (dhcp145-188.rdu.redhat.com [10.13.145.188])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sAQJDveL019775
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:57 -0500
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.8/8.14.5) with ESMTP id sAQJDuGX037721
	for <linux-nfs@vger.kernel.org>; Wed, 26 Nov 2014 14:13:56 -0500
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.8/8.14.8/Submit) id sAQJDuuc037720
	for linux-nfs@vger.kernel.org; Wed, 26 Nov 2014 14:13:56 -0500
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 02/17] mountstats: Add lists of various counters
Date: Wed, 26 Nov 2014 14:13:40 -0500
Message-Id: <1417029235-37675-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
References: <1417029235-37675-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NfsEventCounters and NfsByteCounters were lifted straight from
nfs-iostat.py.  Also added counters for the xprt line (for udp, tcp, and
rdma) as well as for v3 and v4 NFS ops.  These will allow for more
compact code in a couple of places.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/mountstats/mountstats.py | 168 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 168 insertions(+)

diff --git a/tools/mountstats/mountstats.py b/tools/mountstats/mountstats.py
index ab971a4..e36b9ef 100644
--- a/tools/mountstats/mountstats.py
+++ b/tools/mountstats/mountstats.py
@@ -32,6 +32,174 @@ def difference(x, y):
     """
     return x - y
 
+NfsEventCounters = [
+    'inoderevalidates',
+    'dentryrevalidates',
+    'datainvalidates',
+    'attrinvalidates',
+    'vfsopen',
+    'vfslookup',
+    'vfspermission',
+    'vfsupdatepage',
+    'vfsreadpage',
+    'vfsreadpages',
+    'vfswritepage',
+    'vfswritepages',
+    'vfsreaddir',
+    'vfssetattr',
+    'vfsflush',
+    'vfsfsync',
+    'vfslock',
+    'vfsrelease',
+    'congestionwait',
+    'setattrtrunc',
+    'extendwrite',
+    'sillyrenames',
+    'shortreads',
+    'shortwrites',
+    'delay',
+    'pnfsreads',
+    'pnfswrites'
+]
+
+NfsByteCounters = [
+    'normalreadbytes',
+    'normalwritebytes',
+    'directreadbytes',
+    'directwritebytes',
+    'serverreadbytes',
+    'serverwritebytes',
+    'readpages',
+    'writepages'
+]
+
+XprtUdpCounters = [
+    'port',
+    'bind_count',
+    'rpcsends',
+    'rpcreceives',
+    'badxids',
+    'inflightsends',
+    'backlogutil'
+]
+
+XprtTcpCounters = [
+    'port',
+    'bind_count',
+    'connect_count',
+    'connect_time',
+    'idle_time',
+    'rpcsends',
+    'rpcreceives',
+    'badxids',
+    'inflightsends',
+    'backlogutil'
+]
+
+XprtRdmaCounters = [
+    'port',
+    'bind_count',
+    'connect_count',
+    'connect_time',
+    'idle_time',
+    'rpcsends',
+    'rpcreceives',
+    'badxids',
+    'backlogutil',
+    'read_chunks',
+    'write_chunks',
+    'reply_chunks',
+    'total_rdma_req',
+    'total_rdma_rep',
+    'pullup',
+    'fixup',
+    'hardway',
+    'failed_marshal',
+    'bad_reply'
+]
+
+Nfsv3ops = [
+    'NULL',
+    'GETATTR',
+    'SETATTR',
+    'LOOKUP',
+    'ACCESS',
+    'READLINK',
+    'READ',
+    'WRITE',
+    'CREATE',
+    'MKDIR',
+    'SYMLINK',
+    'MKNOD',
+    'REMOVE',
+    'RMDIR',
+    'RENAME',
+    'LINK',
+    'READDIR',
+    'READDIRPLUS',
+    'FSSTAT',
+    'FSINFO',
+    'PATHCONF',
+    'COMMIT'
+]
+
+Nfsv4ops = [
+    'NULL',
+    'READ',
+    'WRITE',
+    'COMMIT',
+    'OPEN',
+    'OPEN_CONFIRM',
+    'OPEN_NOATTR',
+    'OPEN_DOWNGRADE',
+    'CLOSE',
+    'SETATTR',
+    'FSINFO',
+    'RENEW',
+    'SETCLIENTID',
+    'SETCLIENTID_CONFIRM',
+    'LOCK',
+    'LOCKT',
+    'LOCKU',
+    'ACCESS',
+    'GETATTR',
+    'LOOKUP',
+    'LOOKUP_ROOT',
+    'REMOVE',
+    'RENAME',
+    'LINK',
+    'SYMLINK',
+    'CREATE',
+    'PATHCONF',
+    'STATFS',
+    'READLINK',
+    'READDIR',
+    'SERVER_CAPS',
+    'DELEGRETURN',
+    'GETACL',
+    'SETACL',
+    'FS_LOCATIONS',
+    'RELEASE_LOCKOWNER',
+    'SECINFO',
+    'FSID_PRESENT',
+    'EXCHANGE_ID',
+    'CREATE_SESSION',
+    'DESTROY_SESSION',
+    'SEQUENCE',
+    'GET_LEASE_TIME',
+    'RECLAIM_COMPLETE',
+    'LAYOUTGET',
+    'GETDEVICEINFO',
+    'LAYOUTCOMMIT',
+    'LAYOUTRETURN',
+    'SECINFO_NO_NAME',
+    'TEST_STATEID',
+    'FREE_STATEID',
+    'GETDEVICELIST',
+    'BIND_CONN_TO_SESSION',
+    'DESTROY_CLIENTID'
+]
+
 class DeviceData:
     """DeviceData objects provide methods for parsing and displaying
     data for a single mount grabbed from /proc/self/mountstats
-- 
1.9.3

