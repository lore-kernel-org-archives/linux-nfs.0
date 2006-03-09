From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 14] knfsd: Create cache_lookup function instead of using a macro to declare one.
Date: Thu, 9 Mar 2006 17:51:43 +1100
Message-ID: <1060309065143.24557@suse.de>
References: <20060309174755.24381.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FHF0x-0000Yb-KH
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:47 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FHF0x-0006xZ-0c
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 22:52:47 -0800
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
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


The C++-like 'template' approach proves to be too ugly and hard
to work with.

The old 'template' won't go away until all users are updated.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/cache.h |   12 +++++
 ./net/sunrpc/cache.c           |   98 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff ./include/linux/sunrpc/cache.h~current~ ./include/linux/sunrpc/cache.h
--- ./include/linux/sunrpc/cache.h~current~	2006-03-09 17:15:13.000000000 +1100
+++ ./include/linux/sunrpc/cache.h	2006-03-09 17:15:14.000000000 +1100
@@ -81,6 +81,11 @@ struct cache_detail {
 					      struct cache_detail *cd,
 					      struct cache_head *h);
 
+	struct cache_head *	(*alloc)(void);
+	int			(*match)(struct cache_head *orig, struct cache_head *new);
+	void			(*init)(struct cache_head *orig, struct cache_head *new);
+	void			(*update)(struct cache_head *orig, struct cache_head *new);
+
 	/* fields below this comment are for internal use
 	 * and should not be touched by cache owners
 	 */
@@ -237,6 +242,13 @@ RTN *FNAME ARGS										\
 	& FUNC##_cache, FUNC##_hash(item), FUNC##_match(item, tmp),	\
 	STRUCT##_init(new, item), STRUCT##_update(tmp, item))
 
+extern struct cache_head *
+sunrpc_cache_lookup(struct cache_detail *detail,
+		    struct cache_head *key, int hash);
+extern struct cache_head *
+sunrpc_cache_update(struct cache_detail *detail,
+		    struct cache_head *new, struct cache_head *old, int hash);
+
 
 #define cache_for_each(pos, detail, index, member) 						\
 	for (({read_lock(&(detail)->hash_lock); index = (detail)->hash_size;}) ;		\

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2006-03-09 17:12:58.000000000 +1100
+++ ./net/sunrpc/cache.c	2006-03-09 17:15:14.000000000 +1100
@@ -47,6 +47,104 @@ void cache_init(struct cache_head *h)
 	h->last_refresh = now;
 }
 
+struct cache_head *sunrpc_cache_lookup(struct cache_detail *detail,
+				       struct cache_head *key, int hash)
+{
+	struct cache_head **head,  **hp;
+	struct cache_head *new = NULL;
+
+	head = &detail->hash_table[hash];
+
+	read_lock(&detail->hash_lock);
+
+	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
+		struct cache_head *tmp = *hp;
+		if (detail->match(tmp, key)) {
+			cache_get(tmp);
+			read_unlock(&detail->hash_lock);
+			return tmp;
+		}
+	}
+	read_unlock(&detail->hash_lock);
+	/* Didn't find anything, insert an empty entry */
+
+	new = detail->alloc();
+	if (!new)
+		return NULL;
+	cache_init(new);
+
+	write_lock(&detail->hash_lock);
+
+	/* check if entry appeared while we slept */
+	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
+		struct cache_head *tmp = *hp;
+		if (detail->match(tmp, key)) {
+			cache_get(tmp);
+			write_unlock(&detail->hash_lock);
+			detail->cache_put(new, detail);
+			return tmp;
+		}
+	}
+	detail->init(new, key);
+	new->next = *head;
+	*head = new;
+	detail->entries++;
+	cache_get(new);
+	write_unlock(&detail->hash_lock);
+
+	return new;
+}
+EXPORT_SYMBOL(sunrpc_cache_lookup);
+
+struct cache_head *sunrpc_cache_update(struct cache_detail *detail,
+				       struct cache_head *new, struct cache_head *old, int hash)
+{
+	/* The 'old' entry is to be replaced by 'new'.
+	 * If 'old' is not VALID, we update it directly,
+	 * otherwise we need to replace it
+	 */
+	struct cache_head **head;
+	struct cache_head *tmp;
+
+	if (!test_bit(CACHE_VALID, &old->flags)) {
+		write_lock(&detail->hash_lock);
+		if (!test_bit(CACHE_VALID, &old->flags)) {
+			if (test_bit(CACHE_NEGATIVE, &new->flags))
+				set_bit(CACHE_NEGATIVE, &old->flags);
+			else
+				detail->update(old, new);
+			/* FIXME cache_fresh should come first */
+			write_unlock(&detail->hash_lock);
+			cache_fresh(detail, old, new->expiry_time);
+			return old;
+		}
+		write_unlock(&detail->hash_lock);
+	}
+	/* We need to insert a new entry */
+	tmp = detail->alloc();
+	if (!tmp) {
+		detail->cache_put(old, detail);
+		return NULL;
+	}
+	cache_init(tmp);
+	detail->init(tmp, old);
+	head = &detail->hash_table[hash];
+
+	write_lock(&detail->hash_lock);
+	if (test_bit(CACHE_NEGATIVE, &new->flags))
+		set_bit(CACHE_NEGATIVE, &tmp->flags);
+	else
+		detail->update(tmp, new);
+	tmp->next = *head;
+	*head = tmp;
+	cache_get(tmp);
+	write_unlock(&detail->hash_lock);
+	cache_fresh(detail, tmp, new->expiry_time);
+	cache_fresh(detail, old, 0);
+	detail->cache_put(old, detail);
+	return tmp;
+}
+EXPORT_SYMBOL(sunrpc_cache_update);
 
 static int cache_make_upcall(struct cache_detail *detail, struct cache_head *h);
 /*


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
