From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/2] mountd: clean up rmtab handling
Date: Mon, 4 Dec 2006 15:38:09 +1100
Message-ID: <17779.42545.642976.873602@cse.unsw.edu.au>
References: <1161781620.7078.50.camel@dantu.rdu.redhat.com>
	<45704A4A.6000007@poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gr5al-0003aK-MR
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 20:38:11 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gr5ak-0002Kg-68
	for nfs@lists.sourceforge.net; Sun, 03 Dec 2006 20:38:13 -0800
To: Jeff Layton <jlayton@poochiereds.net>
In-Reply-To: message from Jeff Layton on Friday December 1
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

On Friday December 1, jlayton@poochiereds.net wrote:
> Jeff Layton wrote:
> > We have had a few reports from customers that showmount -a is just plain
> > broken.
> 
> ...
> 
> > The following two patches remedy this. They both should only affect the
> > case where new_cache is set.
> > 
> > -- Jeff
> 
> It's been a little over a month since I originally posted these patches 
> and haven't received much comment though Neil and I have traded some 
> emails off list concerning it. I'd like to move the discussion back to 
> the mailing list to get a wider audience and see if we can come to some 
> sort of resolution.
> 
> When we last communicated, he mentioned a scheme whereby we could 
> generate the showmount -a info on the fly rather than trying to maintain 
> the rmtab. That sounds like a good approach, but I don't see how that 
> can work without some changes in how the caches are managed.
> 
> Neil, would it be reasonable to commit these patches now to fix the 
> immediate problem and then work on the new scheme that synthesizes the 
> info out of the kernel caches like you proposed?

I'm not convinced... I don't like the idea of mapping an IP address to
a hostname and then just working with the hostname.  Because it is
really IP addresses that you trust, not host names (in the case of
multi-homed hosts particularly).

The following patch is a first cut at using the kernel caches for
providing the information for "showmount -a".

Note that this does *not* list precisely those hosts which currently
have filesystems mounted, and precisely which filesystems.  That
information is simply not available reliably.

What it does do is list all the 
  IP-address   exportpoint
combinations that could possibly have been used in the last half hour.

As an example of how this will be less precise than you might like,
suppose you export
       /foo @hostgroup()
       /bar @hostgroup()

and suppose 1.2.3.4 and 5.6.7.8 both map to hosts in @hostgroup.

Support further than 1.2.3.4 has mounted and accessed /foo recently,
and 5.6.7.8 has mounted and accessed /bar recently.

Then the kernel will know:

   1.2.3.4 -> @hostgroup
   5.6.7.8 -> @hostgroup

   @hostgroup can access /foo
   @hostgroup can access /bar

Then this patch will cause "showmount -a" to report

   1.2.3.4:/foo
   1.2.3.4:/bar
   5.6.7.8:/foo
   5.6.7.8:/bar
   @hostgroup:/foo
   @hostgroup:/bar

It would be possible (thought I would rather make it optional) to give
the kernel more fine detail. i.e. not group multiple IP addresses
under the one client name but give each IP address it's own name.
This you would have

    1.2.3.4 -> 1.2.3.4
    5.6.7.8 -> 5.6.7.8

    1.2.3.4 can access /foo
    5.6.7.8 can access /bar

and "showmount -a" would then list

     1.2.3.4:/foo
     5.6.7.8:/bar

but again this would only be if there were accesses in the last half
hour (though that could be configurable too I guess).

Finally we could still leave the authentication the way it is and just
fix up the rmtab entries.
So whenever mountd gives info to the kernel, whether due to a mount
request or an up-call, we write an appropriate IP:/dir to rmtab, and
whenever an unmount request is received, we deleted the corresponding
request.
We could do this ignoring the current count in rmtab, and still have a
fairly reliable system.  We would probably want to erase rmtab at boot
time to stop it from collection cruft.

Actually, that sounds like it could be the best idea.  I'll have a go
at that, but I'll post this patch (That gets info from the in-kernel
cache) anyway.

NeilBrown


diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 3e868d8..31e2b75 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -140,7 +140,7 @@ int qword_get(char **bpp, char *dest, int bufsize)
 		}
 	} else {
 		/* text with \nnn octal quoting */
-		while (*bp != ' ' && *bp != '\n' && *bp && len < bufsize-1) {
+		while (*bp != ' ' && *bp != '\t' && *bp != '\n' && *bp && len < bufsize-1) {
 			if (*bp == '\\' &&
 			    isodigit(bp[1]) && (bp[1] <= '3') &&
 			    isodigit(bp[2]) &&
@@ -158,9 +158,9 @@ int qword_get(char **bpp, char *dest, int bufsize)
 		}
 	}
 
-	if (*bp != ' ' && *bp != '\n' && *bp != '\0')
+	if (*bp != ' ' && *bp != '\t' && *bp != '\n' && *bp != '\0')
 		return -1;
-	while (*bp == ' ') bp++;
+	while (*bp == ' ' || *bp == '\t') bp++;
 	*bpp = bp;
 	*dest = '\0';
 	return len;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index c57d3b0..d99f22f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -83,9 +83,6 @@ void auth_unix_ip(FILE *f)
 		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
 
-	if (client && strcmp(ipaddr, client))
-		mountlist_add(ipaddr, *client?client:"DEFAULT");
-
 	if (client) free(client);
 	
 }
@@ -295,7 +292,6 @@ void nfsd_export(FILE *f)
 		qword_printint(f, found->m_export.e_anonuid);
 		qword_printint(f, found->m_export.e_anongid);
 		qword_printint(f, found->m_export.e_fsid);
-		mountlist_add(dom, path);
 	}
 	qword_eol(f);
  out:
@@ -374,7 +370,6 @@ void cache_export_ent(char *domain, struct exportent *exp)
 
 	fclose(f);
 
-	mountlist_add(domain, exp->e_path);
 }
 
 void cache_export(nfs_export *exp)
@@ -393,9 +388,6 @@ void cache_export(nfs_export *exp)
 	
 	fclose(f);
 
-	if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-		mountlist_add(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-
 	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
 }
 
@@ -433,3 +425,84 @@ cache_get_filehandle(nfs_export *exp, int len, char *p)
 	return &fh;
 }
 
+mountlist
+cache_mountlist_list(void)
+{
+	/* Read /proc/net/rpc/auth.unix.ip/content and
+	 *      /proc/net/rpc/nfsd.export/content
+	 * and construct a mountlist from that.
+	 * Every entry in nfsd.export creates a mountlist entry.
+	 * Then every entry in auth.unix.ip which matches an already
+	 * created entry creates another entry.
+	 */
+	static mountlist mlist = NULL;
+	mountlist mlist_base;
+	char buf[8192];
+	FILE *f;
+
+	while (mlist) {
+		mountlist m = mlist;
+		mlist = mlist->ml_next;
+		xfree(m->ml_hostname);
+		xfree(m->ml_directory);
+		xfree(m);
+	}
+
+	f = fopen("/proc/net/rpc/nfsd.export/content", "r");
+	if (!f)
+		return mlist;
+
+	while (fgets(buf, sizeof(buf), f) != NULL) {
+		char *cp;
+		char path[1024], host[1024];
+		mountlist m;
+
+		if (buf[0] == '#' || buf[0] == '\n' || buf[0] == '\0')
+			continue;
+		cp = buf;
+		qword_get(&cp, path, 1024);
+		qword_get(&cp, host, 1024);
+
+		cp = strchr(host, '(');
+		if (cp)
+			*cp = 0;
+		m = (mountlist) xmalloc(sizeof(*m));
+		m->ml_hostname = xstrdup(host);
+		m->ml_directory = xstrdup(path);
+		m->ml_next = mlist;
+		mlist = m;
+	}
+	fclose(f);
+
+
+	f = fopen("/proc/net/rpc/auth.unix.ip/content", "r");
+	if (!f)
+		return mlist;
+
+	mlist_base = mlist;
+	while (fgets(buf, sizeof(buf), f) != NULL) {
+		char *cp;
+		char ip[1024], host[1024];
+		mountlist m, mp;
+
+		if (buf[0] == '#' || buf[0] == '\n' || buf[0] == '\0')
+			continue;
+		if (strncmp(buf, "nfsd ", 5) != 0)
+			continue;
+		cp = buf+5;
+		qword_get(&cp, ip, 1024);
+		qword_get(&cp, host, 1024);
+
+		for (mp = mlist_base; mp; mp = mp->ml_next)
+			if (strcmp(mp->ml_hostname, host) == 0) {
+				m = (mountlist) xmalloc(sizeof(*m));
+				m->ml_hostname = xstrdup(ip);
+				m->ml_directory = xstrdup(mp->ml_directory);
+				m->ml_next = mlist;
+				mlist = m;
+				break;
+			}
+	}
+	fclose(f);
+	return mlist;
+}
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index f40d367..5aa3c83 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -198,7 +198,11 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
 
-	if ((*res = mountlist_list()) == NULL)
+	if (new_cache)
+		*res = cache_mountlist_list();
+	else
+		*res = mountlist_list();
+	if (*res == NULL)
 		xlog(L_WARNING, "dump request from %s failed.",
 			inet_ntoa(addr->sin_addr));
 
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index d64c171..ecaaff9 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -49,6 +49,7 @@ void		mountlist_add(char *host, const char *path);
 void		mountlist_del(char *host, const char *path);
 void		mountlist_del_all(struct sockaddr_in *sin);
 mountlist	mountlist_list(void);
+mountlist	cache_mountlist_list(void);
 
 
 #endif /* MOUNTD_H */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
