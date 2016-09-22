Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:37828 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757385AbcIVOq7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 22 Sep 2016 10:46:59 -0400
Date: Thu, 22 Sep 2016 10:46:57 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [0/2] make nfsd's setclientid behavior migration-friendly
Message-ID: <20160922144657.GC30401@fieldses.org>
References: <1474481025-23702-1-git-send-email-bfields@redhat.com>
 <1474542423.1706.4.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1474542423.1706.4.camel@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 22, 2016 at 07:07:03AM -0400, Jeff Layton wrote:
> On Wed, 2016-09-21 at 14:03 -0400, J. Bruce Fields wrote:
> > Clients mounting multiple servers with the "migration" option may find
> > some mounts are made from the incorrect server.
> > 
> > I think this is really a bug in RFC 7931, and that RFC and the client
> > need fixing, but this is easy to mitigate on the server.  I'll make an
> > attempt at a client patch too.
> > 
> > --b.
> > 
> > 
> 
> Both look reasonable to me:
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Thanks.  The below (untested) is what I was thinking of for the client.

--b.

commit 0d210faff69c
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Sep 21 15:49:21 2016 -0400

    nfs: fix false positives in nfs40_walk_client_list()
    
    It's possible that two different servers can return the same (clientid,
    verifier) pair purely by coincidence.  Both are 64-bit values, but
    depending on the server implementation, they can be highly predictable
    and collisions may be quite likely, especially when there are lots of
    servers.
    
    So, check for this case.  If the clientid and verifier both match, then
    we actually know they *can't* be the same server, since a new
    SETCLIENTID to an already-known server should have changed the verifier.
    
    This helps fix a bug that could cause the client to mount a filesystem
    from the wrong server.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index cd3b7cfdde16..a8cdb94d313c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -461,6 +461,11 @@ static bool nfs4_match_client_owner_id(const struct nfs_client *clp1,
 	return strcmp(clp1->cl_owner_id, clp2->cl_owner_id) == 0;
 }
 
+static bool nfs4_same_verifier(nfs4_verifier *v1, nfs4_verifier *v2)
+{
+	return 0 == memcmp(v1->data, v2->data, sizeof(v1->data));
+}
+
 /**
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
@@ -518,7 +523,20 @@ int nfs40_walk_client_list(struct nfs_client *new,
 
 		if (!nfs4_match_client_owner_id(pos, new))
 			continue;
-
+		/*
+		 * We just sent a new SETCLIENTID, which should have
+		 * caused the server to return a new cl_confirm.  So if
+		 * cl_confirm is the same, then this is a different
+		 * server that just returned the same cl_confirm by
+		 * coincidence:
+		 */
+		if (nfs4_same_verifier(&pos->cl_confirm, &new->cl_confirm))
+			continue;
+		/*
+		 * But if the cl_confirm's are different, then the only
+		 * way that a SETCLIENTID_CONFIRM to pos can succeed is
+		 * if new and pos point to the same server:
+		 */
 		atomic_inc(&pos->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 
