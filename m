From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] fix regression with rmtab handling in newer nfs-utils
	code
Date: Mon, 6 Aug 2007 19:18:58 -0400
Message-ID: <20070806191858.0afaaa91.jlayton@redhat.com>
References: <20070806155500.25869737.jlayton@redhat.com>
	<4d569c330708061501n501e37dcr6d98800618b4ea4d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, iisaman@citi.umich.edu, nfs@lists.sourceforge.net
To: "Kevin Coffman" <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIBqj-0005qx-92
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 16:18:57 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IIBqm-0005uv-VY
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 16:19:01 -0700
In-Reply-To: <4d569c330708061501n501e37dcr6d98800618b4ea4d@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 6 Aug 2007 18:01:27 -0400
"Kevin Coffman" <kwc@citi.umich.edu> wrote:

> On 8/6/07, Jeff Layton <jlayton@redhat.com> wrote:
> > I just noticed that there seems to have been a regression with how the
> > rmtab is handled in the latest nfs-utils code. It seems to have gone
> > back to adding extra lines to the rmtab that contain the comma-delimited
> > domain string.
> >
> > At first glance, it looks like the extra mountlist_add calls that went
> > in with the patch below are the culprit (though this code seems to have
> > changed a few times since then). I don't think there's any need to
> > have cache_export_ent or nfsd_fh call mountlist_add.
> >
> > Can these calls just be removed, or am I missing something?
> >
> > commit dbfcba5b03481d49f3e78946fe8fd066e2025545
> > Author: Kevin Coffman <kwc@citi.umich.edu>
> > Date:   Thu Feb 8 17:27:45 2007 -0500
> >
> >     Remove duplicated code.
> >
> >     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
> >     Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
> >
> >     Remove duplicated code.
> >     Signed-off-by: Neil Brown <neilb@suse.de>
> >
> 
> Sorry.  I assume this is my fault while "fixing" conflicts before
> submitting these patches to Neil.
> 
> K.C.

No problem. I just wanted to make sure I wasn't missing something. I
think this patch against the current git tree should fix it:

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index b686318..15100d4 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -649,8 +649,7 @@ void nfsd_export(FILE *f)
 			     "Cannot export %s, possibly unsupported filesystem"
 			     " or fsid= required", path);
 			dump_to_cache(f, dom, path, NULL);
-		} else
-			mountlist_add(dom, path);
+		}
 	} else {
 		dump_to_cache(f, dom, path, NULL);
 	}
@@ -729,7 +728,6 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 		     "Cannot export %s, possibly unsupported filesystem or"
 		     " fsid= required", exp->e_path);
 	}
-	mountlist_add(domain, exp->e_path);
 
 	while (err == 0 && (exp->e_flags & NFSEXP_CROSSMOUNT) && path) {
 		/* really an 'if', but we can break out of

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
