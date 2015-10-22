Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:35389 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965849AbbJVU6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Oct 2015 16:58:25 -0400
Received: from zmail22.collab.prod.int.phx2.redhat.com (zmail22.collab.prod.int.phx2.redhat.com [10.5.83.26])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id t9MKwOou003955
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2015 16:58:24 -0400
Date: Thu, 22 Oct 2015 16:58:24 -0400 (EDT)
From: Frank Sorenson <sorenson@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1686719493.36610358.1445547504794.JavaMail.zimbra@redhat.com>
In-Reply-To: <1652759591.36606461.1445546958744.JavaMail.zimbra@redhat.com>
Subject: mountd does not check for membership of IP addresses in netgroups
 if the IP is resolvable
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If a netgroup entry specifies an IP address, and that IP address
can be resolved to a name, the current match code in mountd only
tests whether the canonical name and any aliases are in the
netgroup, and does not test whether the IP address is in the netgroup.

(IP addresses which do not resolve to a name are already checked
for membership in the netgroup)


The following demonstrates this issue:

/etc/netgroup:
test_netgroup	(127.0.0.1,-,-)

/etc/exports:
/data		@test_netgroup(rw,sync)

# mkdir /data
# mkdir -p /mnt/test
# exportfs -a
# mount localhost:/data /mnt/test

assuming that there is a localhost entry in /etc/hosts, this will fail:
mount.nfs: access denied by server while mounting localhost:/data


The patch below adds the code to test for the IP addresses in
the netgroup, and the mount now succeeds.



Author: Frank Sorenson <sorenson@redhat.com>
Date:   Thu Oct 22 15:38:17 2015 -0500

    mountd: fix netgroup lookup for resolvable IP addresses
    
    If a netgroup entry specifies an IP address, and that
    IP address can be resolved to a name, mountd will
    currently only test whether the canonical name and
    any aliases are in the netgroup, and does not test
    whether the IP address is in the netgroup (IP
    addresses which do not resolve to a name are
    already checked against the netgroup).
    
    This patch adds the check to see whether the IP
    addresses are in the netgroup.
    
    
    Signed-off-by: Frank Sorenson <sorenson@redhat.com>

diff --git a/support/export/client.c b/support/export/client.c
index 95156f0..f6c58f2 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -686,6 +686,21 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 		}
 	}
 
+	/* check whether the IP itself is in the netgroup */
+	for (tmp = ai ; tmp != NULL ; tmp = tmp->ai_next) {
+		free(hname);
+		hname = calloc(INET6_ADDRSTRLEN, 1);
+
+		if (inet_ntop(tmp->ai_family, &(((struct sockaddr_in *)tmp->ai_addr)->sin_addr), hname, INET6_ADDRSTRLEN) != hname) {
+			xlog(D_GENERAL, "  %s: unable to inet_ntop addrinfo %p: %m", __func__, tmp, errno);
+			goto out;
+		}
+		if (innetgr(netgroup, hname, NULL, NULL)) {
+			match = 1;
+			goto out;
+		}
+	}
+
 	/* Okay, strip off the domain (if we have one) */
 	dot = strchr(hname, '.');
 	if (dot == NULL)
