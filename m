From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: Re: questions for exportfs
Date: Thu, 03 Jul 2003 12:52:38 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030703125109.334C.KAKMY@mvh.biglobe.ne.jp>
References: <20030623152823.6981.KAKMY@mvh.biglobe.ne.jp> <16131.34681.2156.480079@gargle.gargle.HOWL>
Reply-To: kakuma@tko.ncs.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Cc: kakuma@tko.ncs.co.jp, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.157])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Xv9L-0006CO-00
	for <nfs@lists.sourceforge.net>; Wed, 02 Jul 2003 20:52:47 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16131.34681.2156.480079@gargle.gargle.HOWL>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi,

Thank you very much for reply.
And thank you very much for making patch.

I would report, if I would become something aware
for following or others.

Fumihiko Kakuma

On Thu, 3 Jul 2003 11:31:37 +1000
Neil Brown <neilb@cse.unsw.edu.au> wrote:

(explain of upper part cut out).

> > In function exports_update of utils/exportfs/exportfs.c:
> > (1)Find entry that belong entry with modified options
> > in exportlist of type except FQDN from exportlist of
> > FQDN type,
> > (2)Set modified options to that entry.
> > (3)After that reflect it client by original update code.
> > 
> 
> uhm... something like that.
> The following patch fixes both the problems, has been commited to the
> nfs-utils CVS on sourceforge and will be in the next release of
> nfs-utils.
> Thankyou very much for your helpful report.
> 
> NeilBrown
> 
> 
> Index: ChangeLog
> ===================================================================
> RCS file: /cvsroot/nfs/nfs-utils/ChangeLog,v
> retrieving revision 1.209
> diff -u -r1.209 ChangeLog
> --- ChangeLog	2 Jul 2003 06:51:21 -0000	1.209
> +++ ChangeLog	3 Jul 2003 01:27:39 -0000
> @@ -1,3 +1,16 @@
> +2003-07-03 NeilBrown <neilb@cse.unsw.edu.au>
> +	fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
> +
> +	* utils/exportfs/exportfs.c(unexportfs): improve host comparison
> +	so as to only export the wildcard exports that were asked for.
> +	* support/export/export.c(export_allowed): changed to return the
> +	nfs_export rather than a "struct exportent", as m_changed is
> +	needed by called
> +	* support/export/rmtab.c(rmtab_read): modified to deal with
> +	interface change for export_allowed(), and enhanced to preserve
> +	m_changed flag when a wild-card export causes the creation of
> +	a non-wildcard export.
> +	
>  2003-07-02 NeilBrown <neilb@cse.unsw.edu.au>
>  	Steve Dickson <SteveD@redhat.com>
>  
> Index: support/export/export.c
> ===================================================================
> RCS file: /cvsroot/nfs/nfs-utils/support/export/export.c,v
> retrieving revision 1.6
> diff -u -r1.6 export.c
> --- support/export/export.c	30 May 2003 05:17:54 -0000	1.6
> +++ support/export/export.c	3 Jul 2003 01:27:39 -0000
> @@ -172,10 +172,9 @@
>  	return NULL;
>  }
>  
> -struct exportent *
> +nfs_export *
>  export_allowed(struct hostent *hp, char *path)
>  {
> -	static struct exportent	ee;
>  	nfs_export		*exp;
>  	char			epath[MAXPATHLEN+1];
>  	char			*p = NULL;
> @@ -188,10 +187,8 @@
>  	/* Try the longest matching exported pathname. */
>  	while (1) {
>  		exp = export_allowed_internal (hp, epath);
> -		if (exp) {
> -			dupexportent(&ee, &exp->m_export);
> -			return &ee;
> -		}
> +		if (exp)
> +			return exp;
>  		/* We have to treat the root, "/", specially. */
>  		if (p == &epath[1]) break;
>  		p = strrchr(epath, '/');
> Index: support/export/rmtab.c
> ===================================================================
> RCS file: /cvsroot/nfs/nfs-utils/support/export/rmtab.c,v
> retrieving revision 1.4
> diff -u -r1.4 rmtab.c
> --- support/export/rmtab.c	20 Sep 2001 00:37:17 -0000	1.4
> +++ support/export/rmtab.c	3 Jul 2003 01:27:39 -0000
> @@ -25,7 +25,6 @@
>  
>  	setrmtabent("r");
>  	while ((rep = getrmtabent(1, NULL)) != NULL) {
> -		struct exportent	*xp;
>  		struct hostent		*hp = NULL;
>  		int			htype;
>  		
> @@ -33,22 +32,23 @@
>  		if (htype == MCL_FQDN
>  		    && (hp = gethostbyname (rep->r_client))
>  		    && (hp = hostent_dup (hp),
> -			xp = export_allowed (hp, rep->r_path))) {
> +			exp = export_allowed (hp, rep->r_path))) {
>  			/* see if the entry already exists, otherwise this was an instantiated
>  			 * wild card, and we must add it
>  			 */
> -			exp = export_lookup(rep->r_client, xp->e_path, 0);
> -			if (!exp) {
> -				strncpy (xp->e_hostname, rep->r_client,
> -					 sizeof (xp->e_hostname) - 1);
> -				xp->e_hostname[sizeof (xp->e_hostname) -1] = '\0';
> -				exp = export_create(xp, 0);
> +			nfs_export *exp2 = export_lookup(rep->r_client,
> +							exp->m_export.e_path, 0);
> +			if (!exp2) {
> +				struct exportent ee;
> +				dupexportent(&ee, &exp->m_export);
> +				strncpy (ee.e_hostname, rep->r_client,
> +					 sizeof (ee.e_hostname) - 1);
> +				ee.e_hostname[sizeof (ee.e_hostname) -1] = '\0';
> +				exp2 = export_create(&ee, 0);
> +				exp2->m_changed = exp->m_changed;
>  			}
>  			free (hp);
> -
> -			if (!exp)
> -				continue;
> -			exp->m_mayexport = 1;
> +			exp2->m_mayexport = 1;
>  		} else if (hp) /* export_allowed failed */
>  			free(hp);
>  	}
> Index: support/include/exportfs.h
> ===================================================================
> RCS file: /cvsroot/nfs/nfs-utils/support/include/exportfs.h,v
> retrieving revision 1.5
> diff -u -r1.5 exportfs.h
> --- support/include/exportfs.h	21 May 2003 06:28:13 -0000	1.5
> +++ support/include/exportfs.h	3 Jul 2003 01:27:39 -0000
> @@ -62,7 +62,7 @@
>  void				export_reset(nfs_export *);
>  nfs_export *			export_lookup(char *hname, char *path, int caconical);
>  nfs_export *			export_find(struct hostent *, char *path);
> -struct exportent *		export_allowed(struct hostent *, char *path);
> +nfs_export *			export_allowed(struct hostent *, char *path);
>  nfs_export *			export_create(struct exportent *, int canonical);
>  nfs_export *			export_dup(nfs_export *, struct hostent *);
>  void				export_freeall(void);
> Index: utils/exportfs/exportfs.c
> ===================================================================
> RCS file: /cvsroot/nfs/nfs-utils/utils/exportfs/exportfs.c,v
> retrieving revision 1.11
> diff -u -r1.11 exportfs.c
> --- utils/exportfs/exportfs.c	30 May 2003 05:17:56 -0000	1.11
> +++ utils/exportfs/exportfs.c	3 Jul 2003 01:27:39 -0000
> @@ -283,10 +283,14 @@
>  	for (exp = exportlist[htype]; exp; exp = exp->m_next) {
>  		if (path && strcmp(path, exp->m_export.e_path))
>  			continue;
> -		if (htype != exp->m_client->m_type
> -		    || (htype == MCL_FQDN
> -		        && !matchhostname(exp->m_export.e_hostname,
> -					  hname)))
> +		if (htype != exp->m_client->m_type)
> +			continue;
> +		if (htype == MCL_FQDN
> +		    && !matchhostname(exp->m_export.e_hostname,
> +					  hname))
> +			continue;
> +		if (htype != MCL_FQDN
> +		    && strcasecmp(exp->m_export.e_hostname, hname))
>  			continue;
>  		if (verbose) {
>  #if 0

-- 
角馬　文彦 <kakmy@mvh.biglobe.ne.jp>



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
