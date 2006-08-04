From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH 1 of 4] cpumask: add highest_possible_node_id
Date: Fri, 04 Aug 2006 15:35:19 +1000
Message-ID: <1154669719.21040.2351.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8sLL-0002a5-7G
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:35:31 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G8sLJ-000272-H2
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 22:35:31 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

cpumask: add highest_possible_node_id(), analogous to
highest_possible_processor_id().

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/nodemask.h |    2 ++
 lib/cpumask.c            |   16 ++++++++++++++++
 2 files changed, 18 insertions(+)

Index: linus-git/include/linux/nodemask.h
===================================================================
--- linus-git.orig/include/linux/nodemask.h	2006-07-05 15:55:26.000000000 +1000
+++ linus-git/include/linux/nodemask.h	2006-08-01 15:40:50.953022638 +1000
@@ -352,6 +352,7 @@ extern nodemask_t node_possible_map;
 #define node_possible(node)	node_isset((node), node_possible_map)
 #define first_online_node	first_node(node_online_map)
 #define next_online_node(nid)	next_node((nid), node_online_map)
+int highest_possible_node_id(void);
 #else
 #define num_online_nodes()	1
 #define num_possible_nodes()	1
@@ -359,6 +360,7 @@ extern nodemask_t node_possible_map;
 #define node_possible(node)	((node) == 0)
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)
+#define highest_possible_node_id()	0
 #endif
 
 #define any_online_node(mask)			\
Index: linus-git/lib/cpumask.c
===================================================================
--- linus-git.orig/lib/cpumask.c	2006-07-05 15:55:39.000000000 +1000
+++ linus-git/lib/cpumask.c	2006-08-01 15:42:42.742593668 +1000
@@ -43,3 +43,19 @@ int __any_online_cpu(const cpumask_t *ma
 	return cpu;
 }
 EXPORT_SYMBOL(__any_online_cpu);
+
+#if MAX_NUMNODES > 1
+/*
+ * Find the highest possible node id.
+ */
+int highest_possible_node_id(void)
+{
+	unsigned int node;
+	unsigned int highest = 0;
+
+	for_each_cpu_mask(node, node_possible_map)
+		highest = node;
+	return highest;
+}
+EXPORT_SYMBOL(highest_possible_node_id);
+#endif

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
