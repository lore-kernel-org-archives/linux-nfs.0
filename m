From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] auth_domain_lookup in 2.6.8-rc2
Date: Fri, 8 Oct 2004 12:01:03 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041008100102.GA20142@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="3V7upXqbjpZ4EhLz"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CFrYw-0007ke-Ek
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 03:01:22 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CFrYg-0000gz-TX
	for nfs@lists.sourceforge.net; Fri, 08 Oct 2004 03:01:22 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id ACDC4D0675D
	for <nfs@lists.sourceforge.net>; Fri,  8 Oct 2004 12:01:03 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

2.6.8-rc2 open-codes auth_domain_lookup, and introduces a flaw that
may have security consequences. If we do not find any matching
domain, the routine always returns the last item looked at, no
matter what it was.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #1:
okir@suse.de   |        "I want to use NFS over AX25, can you help me?"
---------------+ 

--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-authdomain-lookup


This patch makes sure that auth_domain_lookup returns NULL when
it doesn't find a matching entry, rather than the last entry
in the hash chain.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: linux-2.6.8/net/sunrpc/svcauth.c
===================================================================
--- linux-2.6.8.orig/net/sunrpc/svcauth.c
+++ linux-2.6.8/net/sunrpc/svcauth.c
@@ -183,7 +183,7 @@ auth_domain_lookup(struct auth_domain *i
 	}
 	/* Didn't find anything */
 	if (!set)
-		goto out_noset;
+		goto out_nada;
 	auth_domain_cache.entries++;
 out_set:
 	set_bit(CACHE_HASHED, &item->h.flags);
@@ -193,6 +193,8 @@ out_set:
 	cache_fresh(&auth_domain_cache, &item->h, item->h.expiry_time);
 	cache_get(&item->h);
 	return item;
+out_nada:
+	tmp = NULL;
 out_noset:
 	read_unlock(&auth_domain_cache.hash_lock);
 	return tmp;

--3V7upXqbjpZ4EhLz--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
