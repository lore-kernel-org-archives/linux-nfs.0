From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Possible bugs in nfs-utils
Date: Fri, 23 Jun 2006 16:33:18 +1000
Message-ID: <1151044398.20487.592.camel@hole.melbourne.sgi.com>
References: <20060619203025.GA7102@us.ibm.com>
	<17563.28793.736537.826927@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Michael Halcrow <mhalcrow@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FtfEZ-0002OR-QZ
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 23:33:39 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FtfEZ-0007Kv-KD
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 23:33:40 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17563.28793.736537.826927@cse.unsw.edu.au>
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

On Fri, 2006-06-23 at 14:39, Neil Brown wrote:
> On Monday June 19, mhalcrow@us.ibm.com wrote:
> > I ran nfs-utils through the Coverity source code scanner, and the
> > following items were flagged that I thought might merit a second

> 
> Below is the patch.  It compiles.
> If you (or anyone) would like to review it...
> 
> Thanks.
> NeilBrown
> 
> 
> >From 2e075a16da4963f54cd556403ca9e15a68de27fd Mon Sep 17 00:00:00 2001
> From: Neil Brown <neilb@suse.de>
> Date: Fri, 23 Jun 2006 14:38:33 +1000
> Subject: [PATCH] Fix various issues discovered by Coverity
> 
> Thanks to Michael Halcrow for finding them.
> ---
>  support/misc/mountpoint.c     |   18 ++++++++++++------
>  support/nfs/cacheio.c         |    6 +++---
>  support/nfs/svc_socket.c      |    2 +-
>  tools/rpcgen/rpc_parse.c      |   11 +----------
>  tools/rpcgen/rpc_scan.c       |    1 +
>  utils/idmapd/cfg.c            |   10 +++++++---
>  utils/idmapd/idmapd.c         |    8 +++++---
>  utils/rquotad/rquota_server.c |    3 ++-
>  utils/statd/notlist.c         |    6 +++++-
>  9 files changed, 37 insertions(+), 28 deletions(-)
> 
> diff --git a/support/misc/mountpoint.c b/support/misc/mountpoint.c
> index 6d0f34e..2cf1324 100644
> --- a/support/misc/mountpoint.c
> +++ b/support/misc/mountpoint.c
> @@ -20,15 +20,21 @@ is_mountpoint(char *path)
>  	 */
>  	char *dotdot;
>  	struct stat stb, pstb;
> +	int rv;
>  
>  	dotdot = malloc(strlen(path)+4);
> +	if (!dotdot)
> +		return 0;

This isn't right; if malloc() fails you can't conclude that
the argument isn't a mountpoint, and you shouldn't tell the
caller that.

How about using the xmalloc() routine in support/nfs/xcommon.c ?
It cannot return NULL and will exit() with a warning should
malloc() fail, which is better than a subtle logic error.

Hmm, actually, looking at xmalloc() it has a problem.  It
does a gettext() and vfprintf() in the failure path, both
of which might fail when we're out of memory.

>  	strcat(strcpy(dotdot, path), "/..");
>  	if (lstat(path, &stb) != 0 ||
>  	    lstat(dotdot, &pstb) != 0)
> -		return 0;
> -
> -	if (stb.st_dev != pstb.st_dev
> -	    || stb.st_ino == pstb.st_ino)
> -		return 1;
> -	return 0;
> +		rv = 0;
> +	else
> +		if (stb.st_dev != pstb.st_dev ||
> +		    stb.st_ino == pstb.st_ino)
> +			rv = 1;
> +		else
> +			rv = 0;
> +	free(dotdot);
> +	return rv;

Yep.

>  }
> diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
> index d7ad429..3e868d8 100644
> --- a/support/nfs/cacheio.c
> +++ b/support/nfs/cacheio.c
> @@ -259,9 +259,9 @@ cache_flush(int force)
>  		"nfsd.export",
>  		NULL
>  	};
> -	stb.st_mtime = time(0);
> -	if (!force)
> -		stat(_PATH_ETAB, &stb);
> +	if (force ||
> +	    stat(_PATH_ETAB, &stb) != 0)
> +		stb.st_mtime = time(0);
>  	
>  	sprintf(stime, "%ld\n", stb.st_mtime);
>  	for (c=0; cachelist[c]; c++) {

Yep.

> diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
> index 888c915..c41a1a3 100644
> --- a/support/nfs/svc_socket.c
> +++ b/support/nfs/svc_socket.c
> @@ -42,7 +42,7 @@ svc_socket (u_long number, int type, int
>    socklen_t len = sizeof (struct sockaddr_in);
>    char rpcdata [1024], servdata [1024];
>    struct rpcent rpcbuf, *rpcp;
> -  struct servent servbuf, *servp;
> +  struct servent servbuf, *servp = NULL;
>    int sock, ret;
>    const char *proto = protocol == IPPROTO_TCP ? "tcp" : "udp";
>  

Yep.

> diff --git a/tools/rpcgen/rpc_parse.c b/tools/rpcgen/rpc_parse.c
> index 577312e..70d1260 100644
> --- a/tools/rpcgen/rpc_parse.c
> +++ b/tools/rpcgen/rpc_parse.c
> @@ -94,6 +94,7 @@ get_definition(void)
>  		def_const(defp);
>  		break;
>  	case TOK_EOF:
> +		free(defp);
>  		return (NULL);
>  	default:
>  		error("definition keyword expected");

Yep.

Interesting that Coverity doesn't complain about the return value
of the ALLOC() macro not being checked for NULL, as ALLOC() is just
a trivial wrapper for malloc().

> @@ -290,7 +291,6 @@ def_union(definition *defp)
>    declaration dec;
>    case_list *cases;
>    case_list **tailp;
> -  int flag;
>  
>    defp->def_kind = DEF_UNION;
>    scan(TOK_IDENT, &tok);
> @@ -309,7 +309,6 @@ def_union(definition *defp)
>      cases->case_name = tok.str;
>      scan(TOK_COLON, &tok);
>      /* now peek at next token */
> -    flag=0;
>      if(peekscan(TOK_CASE,&tok))
>        {
>  
> @@ -325,14 +324,6 @@ def_union(definition *defp)
>        
>  	  }while(peekscan(TOK_CASE,&tok));
>        }
> -    else
> -      if(flag)
> -	{
> -
> -	  *tailp = cases;
> -	  tailp = &cases->next;
> -	  cases = ALLOC(case_list);
> -	};
>  
>      get_declaration(&dec, DEF_UNION);
>      cases->case_decl = dec;

Yep.

> diff --git a/tools/rpcgen/rpc_scan.c b/tools/rpcgen/rpc_scan.c
> index 62d906d..51eecfe 100644
> --- a/tools/rpcgen/rpc_scan.c
> +++ b/tools/rpcgen/rpc_scan.c
> @@ -468,6 +468,7 @@ docppline(char *line, int *lineno, char 
>  	*p = 0;
>  	if (*file == 0) {
>  		*fname = NULL;
> +		free(file);
>  	} else {
>  		*fname = file;
>  	}

Yep.

Same comment about the alloc() macro as about ALLOC().

> diff --git a/utils/idmapd/cfg.c b/utils/idmapd/cfg.c
> index b22a7c9..16d392a 100644
> --- a/utils/idmapd/cfg.c
> +++ b/utils/idmapd/cfg.c
> @@ -487,8 +487,10 @@ conf_get_list (char *section, char *tag)
>        if (!node)
>  	goto cleanup;
>        node->field = strdup (field);
> -      if (!node->field)
> +      if (!node->field) {
> +	free(node);
>  	goto cleanup;
> +      }
>        TAILQ_INSERT_TAIL (&list->fields, node, link);
>      }
>    free (liststr);

Yep (albeit, as you point out, futile).

> @@ -523,8 +525,10 @@ conf_get_tag_list (char *section)
>  	if (!node)
>  	  goto cleanup;
>  	node->field = strdup (cb->tag);
> -	if (!node->field)
> +	if (!node->field) {
> +	  free(node);
>  	  goto cleanup;
> +	}
>  	TAILQ_INSERT_TAIL (&list->fields, node, link);
>        }
>    return list;

Ditto.

> @@ -708,7 +712,7 @@ conf_remove (int transaction, char *sect
>    return 0;
>  
>   fail:
> -  if (node->section)
> +  if (node && node->section)
>      free (node->section);
>    if (node)
>      free (node);

Yep.

> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index 158feaf..1231db4 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -1003,9 +1003,11 @@ mydaemon(int nochdir, int noclose)
>  
>  	if (noclose == 0) {
>  		tempfd = open("/dev/null", O_RDWR);
> -		dup2(tempfd, 0);
> -		dup2(tempfd, 1);
> -		dup2(tempfd, 2);
> +		if (tempfd >= 0) {
> +			dup2(tempfd, 0);
> +			dup2(tempfd, 1);
> +			dup2(tempfd, 2);
> +		}
>  		closeall(3);
>  	}

I don't think this is right.  In the unlikely event that /dev/null
isn't there, we don't want to continue with the original std{in,out,err}
as it might have implications for the process' controlling terminal.
I think it might be better to either exit or try to open something
even more reliable like "/" (being a directory, write()s to it
should fail).


> diff --git a/utils/rquotad/rquota_server.c b/utils/rquotad/rquota_server.c
> index 109c94e..e3715bd 100644
> --- a/utils/rquotad/rquota_server.c
> +++ b/utils/rquotad/rquota_server.c
> @@ -201,7 +201,6 @@ getquota_rslt *getquotainfo(int flags, c
>  				      free(qfpathname);
>  				      continue;
>  			      }
> -			      free(qfpathname);
>  			      lseek(fd, (long) dqoff(id), L_SET);
>  			      switch (read(fd, &dq_dqb, sizeof(struct dqblk))) {
>  			      case 0:/* EOF */
> @@ -215,6 +214,7 @@ getquota_rslt *getquotainfo(int flags, c
>  				      break;
>  			      default:   /* ERROR */
>  				      close(fd);
> +				      free(qfpathname);
>  				      continue;
>  			      }
>  			      close(fd);
> @@ -228,6 +228,7 @@ getquota_rslt *getquotainfo(int flags, c
>  		      dqb.dqb_btime = dq_dqb.dqb_btime;
>  		      dqb.dqb_itime = dq_dqb.dqb_itime;
>  	      }
> +	      free(qfpathname);
>           endmntent(fp);
>  
>           if (err && (flags & ACTIVE)) {

Yep.

> diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
> index 4f52b1d..98aa6e2 100644
> --- a/utils/statd/notlist.c
> +++ b/utils/statd/notlist.c
> @@ -61,8 +61,12 @@ nlist_new(char *my_name, char *mon_name,
>  	NL_TIMES(new) = MAX_TRIES;
>  	NL_STATE(new) = state;
>  	if (!(NL_MY_NAME(new) = xstrdup(my_name))
> -		       	|| !(NL_MON_NAME(new) = xstrdup(mon_name)))
> +	    || !(NL_MON_NAME(new) = xstrdup(mon_name))) {
> +		if (NL_MY_NAME(new))
> +			free(NL_MY_NAME(new));
> +		free(new);
>  		return NULL;
> +	}
>  
>  	return new;
>  }

Hmm,  it looks like statd has it's own redundant xstrdup()
implementation, but it has the semantics as the other one,
i.e. it never returns NULL.  So these checks for NULL
are superfluous and the code could be simplified thus:


--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -54,15 +54,13 @@ nlist_new(char *my_name, char *mon_name,
 {
        notify_list     *new;
  
-       if (!(new = (notify_list *) xmalloc(sizeof(notify_list))))
-               return NULL;
+       new = (notify_list *) xmalloc(sizeof(notify_list));
        memset(new, 0, sizeof(*new));
  
        NL_TIMES(new) = MAX_TRIES;
        NL_STATE(new) = state;
-       if (!(NL_MY_NAME(new) = xstrdup(my_name))
-                       || !(NL_MON_NAME(new) = xstrdup(mon_name)))
-               return NULL;
+       NL_MY_NAME(new) = xstrdup(my_name);
+       NL_MON_NAME(new) = xstrdup(mon_name);
  
        return new;
 }



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
