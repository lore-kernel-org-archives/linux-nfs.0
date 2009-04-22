From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 0/3] nfs-utils: nfsd support for minor version, take 2
Date: Wed, 22 Apr 2009 15:06:30 +0300
Message-ID: <49EF0846.5030800@panasas.com>
References: <49E2F6E4.2080501@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	Chuck Lever <chuck.lever@oracle.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:9570 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752047AbZDVMGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 08:06:41 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following the discussion we had last week
(see http://linux-nfs.org/pipermail/pnfs/2009-April/007283.html)

I made the following changes:
* minorvers4 enabled by default.
* No new -n option.

This makes minorvers control essentially the same as
the major protocol version.  minorvers4 is enabled by default
and can be disabled using -N 4.1.

On Fedora, /etc/sysconfig/nfs can be changed as follows
to configure the service startup script to disable 4.1:

--- /etc/sysconfig/nfs.orig	2009-04-22 14:57:15.000000000 +0300
+++ /etc/sysconfig/nfs	2009-04-22 14:46:52.000000000 +0300
@@ -26,6 +26,8 @@
 #RPCNFSDARGS="-N 2 -N 3"
 # Turn off v4 protocol support
 #RPCNFSDARGS="-N 4"
+# Turn off v4.1 minorversion support
+RPCNFSDARGS="-N 4.1"
 # Number of nfs server processes to be started.
 # The default is 8. 
 #RPCNFSDCOUNT=8

The patches in this set are:
[PATCH 1/3] utils/nfsd: add support for minorvers4
[PATCH 2/3] utils/nfsd: disable minorvers4 via command line
[PATCH 3/3] utils/nfsd: enable nfs minorvers4 by default

Benny
