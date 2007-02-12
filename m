From: NeilBrown <neilb@suse.de>
Subject: [PATCH 009 of 9] knfsd: nfsd4: fix handling of directories
	without default ACLs
Date: Tue, 13 Feb 2007 10:45:07 +1100
Message-ID: <1070212234507.29358@suse.de>
References: <20070213103941.28958.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGkre-0005eI-V0
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:43 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGkrg-0002Io-Eq
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 15:45:45 -0800
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


From: J. Bruce Fields <bfields@citi.umich.edu>
When setting an ACL that lacks inheritable ACEs on a directory, we
should set a default ACL of zero length, not a default ACL with all bits
denied.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |   21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-02-13 10:38:09.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-02-13 10:38:26.000000000 +1100
@@ -416,6 +416,7 @@ struct posix_ace_state_array {
  * calculated so far: */
 
 struct posix_acl_state {
+	int empty;
 	struct posix_ace_state owner;
 	struct posix_ace_state group;
 	struct posix_ace_state other;
@@ -431,6 +432,7 @@ init_state(struct posix_acl_state *state
 	int alloc;
 
 	memset(state, 0, sizeof(struct posix_acl_state));
+	state->empty = 1;
 	/*
 	 * In the worst case, each individual acl could be for a distinct
 	 * named user or group, but we don't no which, so we allocate
@@ -498,6 +500,20 @@ posix_state_to_acl(struct posix_acl_stat
 	int nace;
 	int i, error = 0;
 
+	/*
+	 * ACLs with no ACEs are treated differently in the inheritable
+	 * and effective cases: when there are no inheritable ACEs, we
+	 * set a zero-length default posix acl:
+	 */
+	if (state->empty && (flags & NFS4_ACL_TYPE_DEFAULT)) {
+		pacl = posix_acl_alloc(0, GFP_KERNEL);
+		return pacl ? pacl : ERR_PTR(-ENOMEM);
+	}
+	/*
+	 * When there are no effective ACEs, the following will end
+	 * up setting a 3-element effective posix ACL with all
+	 * permissions zero.
+	 */
 	nace = 4 + state->users->n + state->groups->n;
 	pacl = posix_acl_alloc(nace, GFP_KERNEL);
 	if (!pacl)
@@ -613,6 +629,8 @@ static void process_one_v4_ace(struct po
 	u32 mask = ace->access_mask;
 	int i;
 
+	state->empty = 0;
+
 	switch (ace2type(ace)) {
 	case ACL_USER_OBJ:
 		if (ace->type == NFS4_ACE_ACCESS_ALLOWED_ACE_TYPE) {
@@ -717,7 +735,8 @@ int nfs4_acl_nfsv4_to_posix(struct nfs4_
 		ret = PTR_ERR(*pacl);
 		goto out_dstate;
 	}
-	*dpacl = posix_state_to_acl(&default_acl_state, flags);
+	*dpacl = posix_state_to_acl(&default_acl_state,
+						flags | NFS4_ACL_TYPE_DEFAULT);
 	if (IS_ERR(*dpacl)) {
 		ret = PTR_ERR(*dpacl);
 		posix_acl_release(*pacl);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
