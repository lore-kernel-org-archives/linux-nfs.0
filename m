From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Fix two problems that can cause rmmod nfsd to die.
Date: Mon, 22 May 2006 11:19:32 +1000
Message-ID: <1060522011932.2462@suse.de>
References: <20060522111746.2437.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964980AbWEVBT6@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "david m. richter" <richterd@citi.umich.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This patch applies to -mm and current -git and should go to Linus
before 2.6.17
Thanks.
NeilBrown

### Comments for Changeset

Both cause the 'entries' count in the export cache to be non-zero
at module removal time, so unregistering that cache fails and results
in an oops.

1/ exp_pseudoroot (used for NFSv4 only) leaks a reference to an export
   entry.
2/ sunrpc_cache_update doesn't increment the entries count when it adds
   an entry.

Thanks to "david m. richter" <richterd@citi.umich.edu> for triggering the
problem and finding one of the bugs.

Cc: "david m. richter" <richterd@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c   |    4 +++-
 ./net/sunrpc/cache.c |    1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2006-05-22 10:55:44.000000000 +1000
+++ ./fs/nfsd/export.c	2006-05-22 10:59:40.000000000 +1000
@@ -1066,9 +1066,11 @@ exp_pseudoroot(struct auth_domain *clp, 
 		rv = nfserr_perm;
 	else if (IS_ERR(exp))
 		rv = nfserrno(PTR_ERR(exp));
-	else
+	else {
 		rv = fh_compose(fhp, exp,
 				fsid_key->ek_dentry, NULL);
+		exp_put(exp);
+	}
 	cache_put(&fsid_key->h, &svc_expkey_cache);
 	return rv;
 }

diff ./net/sunrpc/cache.c~current~ ./net/sunrpc/cache.c
--- ./net/sunrpc/cache.c~current~	2006-05-22 11:02:46.000000000 +1000
+++ ./net/sunrpc/cache.c	2006-05-22 11:03:15.000000000 +1000
@@ -159,6 +159,7 @@ struct cache_head *sunrpc_cache_update(s
 		detail->update(tmp, new);
 	tmp->next = *head;
 	*head = tmp;
+	detail->entries++;
 	cache_get(tmp);
 	is_new = cache_fresh_locked(tmp, new->expiry_time);
 	cache_fresh_locked(old, 0);
