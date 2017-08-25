Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35348 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdHYOXK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Aug 2017 10:23:10 -0400
From: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, marcel@holtmann.org, gustavo@padovan.org,
        johan.hedberg@gmail.com, davem@davemloft.net, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de, stephen@networkplumber.org,
        alex.aring@gmail.com, stefan@osg.samsung.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org, santosh.shilimkar@oracle.com,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, bridge@lists.linux-foundation.org,
        linux-wpan@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-nfs@vger.kernel.org
Cc: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 4/7] ipv4: make net_protocol const
Date: Fri, 25 Aug 2017 19:51:44 +0530
Message-Id: <1503670907-23221-5-git-send-email-bhumirks@gmail.com>
In-Reply-To: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
References: <1503670907-23221-1-git-send-email-bhumirks@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make these const as they are only passed to a const argument of the
function inet_add_protocol.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 net/ipv4/af_inet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d678820..19aee07 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1596,7 +1596,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 };
 #endif
 
-static struct net_protocol tcp_protocol = {
+static const struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.early_demux_handler =  tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
@@ -1606,7 +1606,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	.icmp_strict_tag_validation = 1,
 };
 
-static struct net_protocol udp_protocol = {
+static const struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.early_demux_handler =	udp_v4_early_demux,
 	.handler =	udp_rcv,
-- 
1.9.1

