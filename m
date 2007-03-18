From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] [nfs-utils: mountd] exports too verbose.
Date: Mon, 19 Mar 2007 10:23:34 +1100
Message-ID: <17917.51702.109517.90615@notabene.brown>
References: <45F6CB05.6010604@RedHat.com>
	<17913.58996.50116.344398@notabene.brown>
	<45FA9A12.1030602@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HT4iy-0003MO-PY
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:23:41 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HT4iz-0000VY-DZ
	for nfs@lists.sourceforge.net; Sun, 18 Mar 2007 16:23:43 -0700
In-Reply-To: message from Steve Dickson on Friday March 16
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

On Friday March 16, SteveD@redhat.com wrote:
> Neil Brown wrote:
> > On Tuesday March 13, SteveD@redhat.com wrote:
> >> This patch is relative to the git tree at:
> >> git://git.infradead.org/~steved/nfs-utils.git
> >> which has been updated to the nfs-utils-1.0.12
> >> release.
> >>
> >> Please consider...
> > 
> > How about this instead...
> > nfs-utils imposes an ordering to some extent.  hostnames first, then 
> > subnets, the wildcards, then netgroups.
> > If the two names are in different places in that ordering, then there
> > really is no need to report anything, as in you case.
> > 
> > OK?
> > 
> > NeilBrown
> > 
> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> > index 6cf24ce..ed7fe35 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -490,6 +490,7 @@ void nfsd_export(FILE *f)
> >  	int i;
> >  	char *dom, *path;
> >  	nfs_export *exp, *found = NULL;
> > +	int found_type = 0;
> >  
> >  
> >  	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
> > @@ -516,9 +517,10 @@ void nfsd_export(FILE *f)
> >  				continue;
> >  			if (strcmp(path, exp->m_export.e_path))
> >  				continue;
> > -			if (!found)
> > +			if (!found) {
> >  				found = exp;
> > -			else {
> > +				found_type = i;
> > +			} else if (found_type == i) {
> >  				xlog(L_WARNING, "%s exported to both %s and %s in %s",
> >  				     path, exp->m_client->m_hostname, found->m_client->m_hostname,
> >  				     dom);
> hmm... isn't there still a possibility that every time
> the mis-orders exported is accessed, the a message will
> be logged? So it might make sense to only log this
> message once, right?

Not on every access, but only every time the info in the kernel-cache
is refreshed.  But yes, probably once each would be best.

> 
> Also since this is a reordering problem, shouldn't the
> logged message say its a re-ordering problem, so
> people will know how to fix it? At this point, the
> message is stating the obvious... which is really
> not that helpful as to how to avoid the message... imho..

The point of the message is really to make the sysadmin aware that
their /etc/exports might not be doing exactly what they expect.
e.g. if you have
/path  @somegroup(ro) @othergroup(rw)

and some host is in both @somegroup and @othergroup, then there is not 
guarantees about whether that host will get 'ro' or 'rw'.
How to fix it some no something that we can even begin to approach
without knowing the intension and expectation of sysadmin.

Anyway, how about this on top of the previous patch...  any
improvement?

Thanks,
NeilBrown

>From e3f2d2262fed12f0f6b77c5ac1c4072d82f1e754 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Mon, 19 Mar 2007 10:22:22 +1100
Subject: [PATCH] Make warning about host matching multiple exports more helpful.

1/ only warn once per export, as it could get too noisy.
2/ make it a little clearer why this might be a problem.
---
 support/export/export.c    |    2 ++
 support/include/exportfs.h |    4 +++-
 utils/exportfs/exportfs.c  |    2 ++
 utils/mountd/cache.c       |    8 +++++---
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index a4b0788..74e1d1b 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -90,6 +90,7 @@ export_init(nfs_export *exp, nfs_client *clp, struct exportent *nep)
 	exp->m_xtabent = 0;
 	exp->m_mayexport = 0;
 	exp->m_changed = 0;
+	exp->m_warned = 0;
 	exp->m_client = clp;
 	clp->m_count++;
 }
@@ -115,6 +116,7 @@ export_dup(nfs_export *exp, struct hostent *hp)
 	new->m_exported = 0;
 	new->m_xtabent = 0;
 	new->m_changed = 0;
+	new->m_warned = 0;
 	export_add(new);
 
 	return new;
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 458611b..431b5ce 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -47,7 +47,9 @@ typedef struct mexport {
 	int			m_exported;	/* known to knfsd. -1 means not sure */
 	int			m_xtabent  : 1,	/* xtab entry exists */
 				m_mayexport: 1,	/* derived from xtabbed */
-				m_changed  : 1; /* options (may) have changed */
+				m_changed  : 1, /* options (may) have changed */
+				m_warned   : 1; /* warned about multiple exports
+						 * matching one client */
 } nfs_export;
 
 extern nfs_client *		clientlist[MCL_MAXTYPES];
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 1eca567..8c3f634 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -218,6 +218,7 @@ export_all(int verbose)
 			exp->m_xtabent = 1;
 			exp->m_mayexport = 1;
 			exp->m_changed = 1;
+			exp->m_warned = 0;
 		}
 	}
 }
@@ -274,6 +275,7 @@ exportfs(char *arg, char *options, int verbose)
 	exp->m_xtabent = 1;
 	exp->m_mayexport = 1;
 	exp->m_changed = 1;
+	exp->m_warned = 0;
 	if (hp) free (hp);
 }
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ed7fe35..5612a9e 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -520,10 +520,12 @@ void nfsd_export(FILE *f)
 			if (!found) {
 				found = exp;
 				found_type = i;
-			} else if (found_type == i) {
-				xlog(L_WARNING, "%s exported to both %s and %s in %s",
-				     path, exp->m_client->m_hostname, found->m_client->m_hostname,
+			} else if (found_type == i && found->m_warned == 0) {
+				xlog(L_WARNING, "%s exported to both %s and %s, "
+				     "arbitrarily choosing options from first",
+				     path, found->m_client->m_hostname, exp->m_client->m_hostname,
 				     dom);
+				found->m_warned = 1;
 			}
 		}
 	}
-- 
1.4.4.4


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
