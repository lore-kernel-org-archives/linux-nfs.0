From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS/RPC modprobe -r sunrpc causes an oops
Date: Mon, 19 Jan 2004 16:21:06 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <400C4A42.5070701@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050407010200030304020701"
Cc: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aigpe-00047o-Kt
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 13:21:14 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aigpe-0001Sb-9E
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 13:21:14 -0800
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------050407010200030304020701
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello,

Here is a patch for the 2.6.1 kernel that fixes an oops
that occurs when the sunrpc module is unloaded.

The problem was the RPC cache_register() call was
not saving entry pointers to the procfs entries it was
creating. So when it came time to dismantle the
entires, a BUG_ON() was tripped in remove_proc_entry()
since the tree was not broken down completely.

Hopefully this will be a candidate for the next release.....

SteveD.

--------------050407010200030304020701
Content-Type: text/plain;
 name="linux-2.6.1-nfs-cachcleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.1-nfs-cachcleanup.patch"

--- linux-2.6.1/include/linux/sunrpc/cache.h.org	2004-01-09 01:59:42.000000000 -0500
+++ linux-2.6.1/include/linux/sunrpc/cache.h	2004-01-19 14:08:44.000000000 -0500
@@ -94,6 +94,8 @@ struct cache_detail {
 	/* fields for communication over channel */
 	struct list_head	queue;
 	struct proc_dir_entry	*proc_ent;
+	struct proc_dir_entry   *flush_ent, *channel_ent, *content_ent; 
+
 	atomic_t		readers;		/* how many time is /chennel open */
 	time_t			last_close;		/* it no readers, when did last close */
 };
--- linux-2.6.1/net/sunrpc/cache.c.org	2004-01-09 01:59:44.000000000 -0500
+++ linux-2.6.1/net/sunrpc/cache.c	2004-01-19 14:25:34.000000000 -0500
@@ -175,9 +175,11 @@ void cache_register(struct cache_detail 
 	if (cd->proc_ent) {
 		struct proc_dir_entry *p;
 		cd->proc_ent->owner = THIS_MODULE;
+		cd->channel_ent = cd->content_ent = NULL;
 		
  		p = create_proc_entry("flush", S_IFREG|S_IRUSR|S_IWUSR,
  				      cd->proc_ent);
+		cd->flush_ent =  p;
  		if (p) {
  			p->proc_fops = &cache_flush_operations;
  			p->owner = THIS_MODULE;
@@ -187,6 +189,7 @@ void cache_register(struct cache_detail 
 		if (cd->cache_request || cd->cache_parse) {
 			p = create_proc_entry("channel", S_IFREG|S_IRUSR|S_IWUSR,
 					      cd->proc_ent);
+			cd->channel_ent = p; 
 			if (p) {
 				p->proc_fops = &cache_file_operations;
 				p->owner = THIS_MODULE;
@@ -196,6 +199,7 @@ void cache_register(struct cache_detail 
  		if (cd->cache_show) {
  			p = create_proc_entry("content", S_IFREG|S_IRUSR|S_IWUSR,
  					      cd->proc_ent);
+			cd->content_ent = p; 
  			if (p) {
  				p->proc_fops = &content_file_operations;
  				p->owner = THIS_MODULE;
@@ -233,6 +237,13 @@ int cache_unregister(struct cache_detail
 	write_unlock(&cd->hash_lock);
 	spin_unlock(&cache_list_lock);
 	if (cd->proc_ent) {
+		if (cd->flush_ent) 
+			remove_proc_entry("flush", cd->proc_ent);
+		if (cd->channel_ent)
+			remove_proc_entry("channel", cd->proc_ent);
+		if (cd->content_ent)
+			remove_proc_entry("content", cd->proc_ent);
+
 		cd->proc_ent = NULL;
 		remove_proc_entry(cd->name, proc_net_rpc);
 	}

--------------050407010200030304020701--



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
