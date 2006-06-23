From: Neil Brown <neilb@suse.de>
Subject: Re: Possible bugs in nfs-utils
Date: Fri, 23 Jun 2006 14:39:21 +1000
Message-ID: <17563.28793.736537.826927@cse.unsw.edu.au>
References: <20060619203025.GA7102@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtdS8-0001oF-Jb
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:39:32 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FtdS7-0002OC-Sp
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:39:32 -0700
To: Michael Halcrow <mhalcrow@us.ibm.com>
In-Reply-To: message from Michael Halcrow on Monday June 19
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

On Monday June 19, mhalcrow@us.ibm.com wrote:
> I ran nfs-utils through the Coverity source code scanner, and the
> following items were flagged that I thought might merit a second
> glance (source from util-linux-2.13-pre7.tar.bz2). Those with a more
> intimate knowledge of the code base can probably help out in
> determining whether some of these really are problematic:
> 
> ---
> support/nfs/svc_socket.c::svc_socket():
> 
> If ret == 0 and rpcp == NULL, then servp is checked for non-NULL
> status before it is initialized.
> ---

I think that combination should be impossible, but I cannot find a
manpage for getrpcbynumber_r to conform it, so I'll just initialise
servp to NULL - it doesn't hurt.

> 
> ---
> utils/rquotad/rquota_server.c::getquotainfo():
> 
> qfpathname may be leaked.
> ---

Oh, the indenting in that file is HORRIBLE...

Yes, I'll move the free(qfpathname) out to a more appropriate level.

> 
> ---
> utils/statd/notlist.c::nlist_new():
> 
> new may be leaked here:
>         if (!(NL_MY_NAME(new) = xstrdup(my_name))
>                         || !(NL_MON_NAME(new) = xstrdup(mon_name)))
>                 return NULL;
> ---

If it is, we are short of memory anyway and will probably die soon,
but I've added a couple of appropriate frees.

> 
> ---
> tools/rpcgen/rpc_parse.c::get_definition():
> 
> defp may be leaked on tok.kind == TOK_EOF.
> ---

Yep.


> 
> ---
> utils/idmapd/cfg.c::conf_get_tag_list():
> 
> node may be leaked here:
>         if (!node->field)
>           goto cleanup;
> ...
>  cleanup:
>   if (list)
>     conf_free_list (list);
>   return 0;
> 
> Same issue in conf_get_list().
> ---

Ok.

> 
> ---
> support/misc/mountpoint.c::is_mountpoint():
> 
> No check for NULL result from malloc here:
>         dotdot = malloc(strlen(path)+4);
>         strcat(strcpy(dotdot, path), "/..");
> 
> dotdot not freed prior to return.
> ---

Fixed.

> 
> ---
> utils/idmapd/cfg.c::conf_remove():
> 
> Dereference NULL pointer:
>   node = conf_trans_node (transaction, CONF_REMOVE);
>   if (!node)
>     goto fail;
> ...
>  fail:
>   if (node->section)
>     free (node->section);
> ---
Make it
	if (node && node->selection)

> 
> ---
> tools/rpcgen/rpc_parse.c::def_const():

You mean def_union.

> 
> Dead code here:
>     flag=0;
>     if(peekscan(TOK_CASE,&tok))
>       {
> 
>         do
>           {
>             scan2(TOK_IDENT, TOK_CHARCONST, &tok);
>             cases->contflag=1;  /* continued case statement */
>             *tailp = cases;
>             tailp = &cases->next;
>             cases = ALLOC(case_list);
>             cases->case_name = tok.str;
>             scan(TOK_COLON, &tok);
> 
>           }while(peekscan(TOK_CASE,&tok));
>       }
>     else
>       if(flag)
>         {
> 
>           *tailp = cases;
>           tailp = &cases->next;
>           cases = ALLOC(case_list);
>         };
> 
> It looks like flag will always be 0 at the if(flag) check.
> ---

Yes.  It appears that once upon a time the code parsed

  case 0:
  case 1:
     stuff

by setting the flag if stuff was (or maybe wasn't) found, so it could
deal with multiple labels for the same stuff.  But it was changed to
peek and the next token and if it was 'case', do the special handling
then.  So 'flag' is no longer needed.  I've removed it.


> 
> ---
> utils/idmapd/idmapd.c::mydaemon():
> 
> tempfd not checked (not likely to be a problem for /dev/null, but just
> in case):
>                 tempfd = open("/dev/null", O_RDWR);
>                 dup2(tempfd, 0);
> ---

As you say, unlikely, and not really harmful anyway, but I've fixed
it.

> 
> ---
> support/nfs/cacheio.c::cache_flush():
> 
> Return value not checked:
> stat(_PATH_ETAB, &stb);
> ---

That is deliberate (I know, because I wrote that bit :-)
I assume that if stat fails it doesn't change the 'struct stat', in
particular, st_mtime stays at what it was set to.
However I'll make the code more readable.

> 
> ---
> tools/rpcgen/rpc_scan.c::docppline():
> 
> Return without freeing storage.
> ---

Only if *file == 0... fixed.

Below is the patch.  It compiles.
If you (or anyone) would like to review it...

Thanks.
NeilBrown


>From 2e075a16da4963f54cd556403ca9e15a68de27fd Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Fri, 23 Jun 2006 14:38:33 +1000
Subject: [PATCH] Fix various issues discovered by Coverity

Thanks to Michael Halcrow for finding them.
---
 support/misc/mountpoint.c     |   18 ++++++++++++------
 support/nfs/cacheio.c         |    6 +++---
 support/nfs/svc_socket.c      |    2 +-
 tools/rpcgen/rpc_parse.c      |   11 +----------
 tools/rpcgen/rpc_scan.c       |    1 +
 utils/idmapd/cfg.c            |   10 +++++++---
 utils/idmapd/idmapd.c         |    8 +++++---
 utils/rquotad/rquota_server.c |    3 ++-
 utils/statd/notlist.c         |    6 +++++-
 9 files changed, 37 insertions(+), 28 deletions(-)

diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
index 6d0f34e..2cf1324 100644
--- a/support/misc/mountpoint.c
+++ b/support/misc/mountpoint.c
@@ -20,15 +20,21 @@ is_mountpoint(char *path)
 	 */
 	char *dotdot;
 	struct stat stb, pstb;
+	int rv;
 
 	dotdot = malloc(strlen(path)+4);
+	if (!dotdot)
+		return 0;
 	strcat(strcpy(dotdot, path), "/..");
 	if (lstat(path, &stb) != 0 ||
 	    lstat(dotdot, &pstb) != 0)
-		return 0;
-
-	if (stb.st_dev != pstb.st_dev
-	    || stb.st_ino == pstb.st_ino)
-		return 1;
-	return 0;
+		rv = 0;
+	else
+		if (stb.st_dev != pstb.st_dev ||
+		    stb.st_ino == pstb.st_ino)
+			rv = 1;
+		else
+			rv = 0;
+	free(dotdot);
+	return rv;
 }
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index d7ad429..3e868d8 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -259,9 +259,9 @@ cache_flush(int force)
 		"nfsd.export",
 		NULL
 	};
-	stb.st_mtime = time(0);
-	if (!force)
-		stat(_PATH_ETAB, &stb);
+	if (force ||
+	    stat(_PATH_ETAB, &stb) != 0)
+		stb.st_mtime = time(0);
 	
 	sprintf(stime, "%ld\n", stb.st_mtime);
 	for (c=0; cachelist[c]; c++) {
diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
index 888c915..c41a1a3 100644
--- a/support/nfs/svc_socket.c
+++ b/support/nfs/svc_socket.c
@@ -42,7 +42,7 @@ svc_socket (u_long number, int type, int
   socklen_t len = sizeof (struct sockaddr_in);
   char rpcdata [1024], servdata [1024];
   struct rpcent rpcbuf, *rpcp;
-  struct servent servbuf, *servp;
+  struct servent servbuf, *servp = NULL;
   int sock, ret;
   const char *proto = protocol == IPPROTO_TCP ? "tcp" : "udp";
 
diff --git a/tools/rpcgen/rpc_parse.c b/tools/rpcgen/rpc_parse.c
index 577312e..70d1260 100644
--- a/tools/rpcgen/rpc_parse.c
+++ b/tools/rpcgen/rpc_parse.c
@@ -94,6 +94,7 @@ get_definition(void)
 		def_const(defp);
 		break;
 	case TOK_EOF:
+		free(defp);
 		return (NULL);
 	default:
 		error("definition keyword expected");
@@ -290,7 +291,6 @@ def_union(definition *defp)
   declaration dec;
   case_list *cases;
   case_list **tailp;
-  int flag;
 
   defp->def_kind = DEF_UNION;
   scan(TOK_IDENT, &tok);
@@ -309,7 +309,6 @@ def_union(definition *defp)
     cases->case_name = tok.str;
     scan(TOK_COLON, &tok);
     /* now peek at next token */
-    flag=0;
     if(peekscan(TOK_CASE,&tok))
       {
 
@@ -325,14 +324,6 @@ def_union(definition *defp)
       
 	  }while(peekscan(TOK_CASE,&tok));
       }
-    else
-      if(flag)
-	{
-
-	  *tailp = cases;
-	  tailp = &cases->next;
-	  cases = ALLOC(case_list);
-	};
 
     get_declaration(&dec, DEF_UNION);
     cases->case_decl = dec;
diff --git a/tools/rpcgen/rpc_scan.c b/tools/rpcgen/rpc_scan.c
index 62d906d..51eecfe 100644
--- a/tools/rpcgen/rpc_scan.c
+++ b/tools/rpcgen/rpc_scan.c
@@ -468,6 +468,7 @@ docppline(char *line, int *lineno, char 
 	*p = 0;
 	if (*file == 0) {
 		*fname = NULL;
+		free(file);
 	} else {
 		*fname = file;
 	}
diff --git a/utils/idmapd/cfg.c b/utils/idmapd/cfg.c
index b22a7c9..16d392a 100644
--- a/utils/idmapd/cfg.c
+++ b/utils/idmapd/cfg.c
@@ -487,8 +487,10 @@ conf_get_list (char *section, char *tag)
       if (!node)
 	goto cleanup;
       node->field = strdup (field);
-      if (!node->field)
+      if (!node->field) {
+	free(node);
 	goto cleanup;
+      }
       TAILQ_INSERT_TAIL (&list->fields, node, link);
     }
   free (liststr);
@@ -523,8 +525,10 @@ conf_get_tag_list (char *section)
 	if (!node)
 	  goto cleanup;
 	node->field = strdup (cb->tag);
-	if (!node->field)
+	if (!node->field) {
+	  free(node);
 	  goto cleanup;
+	}
 	TAILQ_INSERT_TAIL (&list->fields, node, link);
       }
   return list;
@@ -708,7 +712,7 @@ conf_remove (int transaction, char *sect
   return 0;
 
  fail:
-  if (node->section)
+  if (node && node->section)
     free (node->section);
   if (node)
     free (node);
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 158feaf..1231db4 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -1003,9 +1003,11 @@ mydaemon(int nochdir, int noclose)
 
 	if (noclose == 0) {
 		tempfd = open("/dev/null", O_RDWR);
-		dup2(tempfd, 0);
-		dup2(tempfd, 1);
-		dup2(tempfd, 2);
+		if (tempfd >= 0) {
+			dup2(tempfd, 0);
+			dup2(tempfd, 1);
+			dup2(tempfd, 2);
+		}
 		closeall(3);
 	}
 
diff --git a/utils/rquotad/rquota_server.c b/utils/rquotad/rquota_server.c
index 109c94e..e3715bd 100644
--- a/utils/rquotad/rquota_server.c
+++ b/utils/rquotad/rquota_server.c
@@ -201,7 +201,6 @@ getquota_rslt *getquotainfo(int flags, c
 				      free(qfpathname);
 				      continue;
 			      }
-			      free(qfpathname);
 			      lseek(fd, (long) dqoff(id), L_SET);
 			      switch (read(fd, &dq_dqb, sizeof(struct dqblk))) {
 			      case 0:/* EOF */
@@ -215,6 +214,7 @@ getquota_rslt *getquotainfo(int flags, c
 				      break;
 			      default:   /* ERROR */
 				      close(fd);
+				      free(qfpathname);
 				      continue;
 			      }
 			      close(fd);
@@ -228,6 +228,7 @@ getquota_rslt *getquotainfo(int flags, c
 		      dqb.dqb_btime = dq_dqb.dqb_btime;
 		      dqb.dqb_itime = dq_dqb.dqb_itime;
 	      }
+	      free(qfpathname);
          endmntent(fp);
 
          if (err && (flags & ACTIVE)) {
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index 4f52b1d..98aa6e2 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -61,8 +61,12 @@ nlist_new(char *my_name, char *mon_name,
 	NL_TIMES(new) = MAX_TRIES;
 	NL_STATE(new) = state;
 	if (!(NL_MY_NAME(new) = xstrdup(my_name))
-		       	|| !(NL_MON_NAME(new) = xstrdup(mon_name)))
+	    || !(NL_MON_NAME(new) = xstrdup(mon_name))) {
+		if (NL_MY_NAME(new))
+			free(NL_MY_NAME(new));
+		free(new);
 		return NULL;
+	}
 
 	return new;
 }
-- 
1.4.0


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
