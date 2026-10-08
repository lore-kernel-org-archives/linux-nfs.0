Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 271F84EFFD9
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483525; cv=none; b=rEivT+rl2k4GEo32BDYK/WWjplARs8L/NTDlgh+zyW9Fe6JdU6tBsxBUBCMsAHEEdX5ugcr1fcs4AujnWsdNgymBixRWnOoDcscBAtMnHwWqwbp2XLNKufeDtEkjG4PNVlibXVAYZi3JcFXlWwkl1uMg1Nu8Fwf3ZFbDHnkPuow=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483525; c=relaxed/simple;
	bh=9H29U4nzD+M67mqLt6yCRboS95LCKEFKn0r34PvhMxs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=DgipfipCwJ872ECve4Q5EkrOoawO05g4K8J9cqppppKZx6TYjrFvQvT3intbiWc+8HbHZ4Imha9SJa+0BcmmRbvUg3EtRUk7zyPzIZcsQ5JuOfFEhBSdNv8+SToUNUBp5OPl8F5RjYB7gm79zxyGviRxNLXU1GeZpJFGC9qC+Q4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JJdZBkLb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JJdZBkLb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 83BB51F0089A;
	Thu,  8 Oct 2026 18:18:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483524;
	bh=fIIbiDhCN1HxEgtxVrP61ozIsEXALfT2tt11uQL7Des=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JJdZBkLbOmxo1q1E+kGRdNpVx3zHUkgcWPArVO1FJ6/WQyc0rIxq0nYvDooR61lvl
	 JdrarznmiqgX5sXXAUBQ/s6WWP7bVlp2zTUV/HrB09E5EvnPMKaTFxw5wsObEaq/In
	 Y3gIhZp2kTIBSbAHCDTv/4RqIZkaz3kIybMRjfa6t3YA0Szhc3k46sapAYg2yBd67u
	 GG+OznsB9zqSJn7XnCoOjGG7O6hs/4afcMTagfEIF2wtlYiJ+Be8IuuRyBvbCGtpuI
	 tHgKEx0h5gwIm1gDRGCN9PhNtBraffhLVn7mkGWfiac1KeTt4VOI9R1mgW1nHBnWe6
	 GnTnrXoeK9kTA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 08 Oct 2026 14:18:31 -0400
Subject: [PATCH 5/5] NFSD: Honor OPEN4_SHARE_ACCESS_WANT_READ_DELEG on a
 read-write OPEN
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261008-want-read-v1-5-e372262857c8@kernel.org>
References: <20261008-want-read-v1-0-e372262857c8@kernel.org>
In-Reply-To: <20261008-want-read-v1-0-e372262857c8@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3475; i=cel@kernel.org;
 h=from:subject:message-id; bh=9H29U4nzD+M67mqLt6yCRboS95LCKEFKn0r34PvhMxs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx95/22Cazzs0y+9FpFIESU0CN7SvycydvnyCM
 LnLZYlELVWJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfefwAKCRAzarMzb2Z/
 l2+FEACV4DmMVAtW9Ar5zqXDWpu99NdsuDKndvKZsg2YUcRjmab13C71Td4eI7QaDpWMCjpy13o
 uWp0jzLuJ5oYTdnsBoF/OidTjieovVcXQnqW8JYao9IRWQ5VTkWQpnFwq4pyae8S+q+CrbKOY9o
 VXVhy43L9mCeWHh25iM1DHxd9PTrgTkYGJMfMy9xvjuj00yqHrnumD9e2N3pC3JYOnN5rzehF+u
 U7lXJfh0WjivGwQcJcTLYH/7xAs1ehMty5HzNN+SBlpAcSZcnAVaP8gqZ6AMDjd/IOWYwByjeRo
 tkubMaVUGfh902OXoEgYVgrUGNpq98qpd0nyOaMr8D+i29zx15oaSUWEDTWgkE1EPyPRdvpZoyj
 2xLM3e61zTbxQB6fIx8F+LoKcrqMH3vWPNyANTH5TDA0I5p+FHncdj4KG+8j71zvQWjAnCgl2aF
 O3r0r8UZFkmp6xCzrWo735yDVLpc2ri513AFJKAg4s2REhYvMP9pw7voCzefuSOVULqxiY8p/ih
 80I7zUYt9sQC0E/BtXycY5uc8AGuqu4LuYRRu7zpkvnHT1X1cgujtWkw/KbaJHuxlE8xgHHX8KE
 W4oVGrvz4JNiyak+do1yznxIIH6LyoPx2YcSyLHrm55WDR7wpYd8k0u3fd6CmWzORmaDatOd1It
 MVJjMB9gw36XmAw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 18.16.3 defines OPEN4_SHARE_ACCESS_WANT_READ_DELEG
as a request for an OPEN_DELEGATE_READ delegation regardless of the
access bits in the OPEN. NFSD chooses the delegation type from the
access bits alone, so an OPEN for both read and write that sets
WANT_READ_DELEG gets a write delegation.

Any other client's open recalls that write delegation, and another
client's GETATTR triggers a CB_GETATTR. The read delegation the
client asked for survives both. Granting no delegation would also
respect the request, but it withholds a delegation NFSD is able to
grant.

Try for a read delegation when the OPEN sets WANT_READ_DELEG and
includes read access. After this change, a write-only OPEN that
sets WANT_READ_DELEG gets no delegation, with ond_why set to
WND4_RESOURCE. When the OPEN also sets
OPEN4_SHARE_ACCESS_WANT_OPEN_XOR_DELEGATION, return the open
stateid along with the read delegation.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6bb70d50e9d9..920967dd6f84 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6984,6 +6984,12 @@ static bool nfsd4_want_deleg_timestamps(const struct nfsd4_open *open)
 	return open->op_deleg_want & OPEN4_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS;
 }
 
+static bool nfsd4_want_read_deleg(const struct nfsd4_open *open)
+{
+	return (open->op_deleg_want & NFS4_SHARE_WANT_TYPE_MASK) ==
+		OPEN4_SHARE_ACCESS_WANT_READ_DELEG;
+}
+
 static void
 nfs4_delegation_record_grant_slot(struct nfs4_delegation *dp,
 				 const struct nfsd4_compound_state *cstate)
@@ -7041,14 +7047,16 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	 *  We choose to offer a write delegation for OPEN with the
 	 *  OPEN4_SHARE_ACCESS_WRITE access mode to accommodate such clients.
 	 */
-	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE) {
+	if ((open->op_share_access & NFS4_SHARE_ACCESS_WRITE) &&
+	    !nfsd4_want_read_deleg(open)) {
 		nf = find_writeable_file(fp);
 		dl_type = deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG : OPEN_DELEGATE_WRITE;
 	}
 
 	/*
-	 * If the file is being opened O_RDONLY or we couldn't get a O_RDWR
-	 * file for some reason, then try for a read delegation instead.
+	 * A read delegation can go to a client that holds a write open
+	 * of the file: nfsd_breaker_owns_lease() keeps the holder's own
+	 * opens from breaking it.
 	 */
 	if (!nf && (open->op_share_access & NFS4_SHARE_ACCESS_READ)) {
 		nf = find_readable_file(fp);
@@ -7325,7 +7333,7 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stid.sc_stateid, sizeof(dp->dl_stid.sc_stateid));
 
-	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE) {
+	if (deleg_is_write(dp->dl_type)) {
 		struct file *f;
 
 		f = rcu_dereference_protected(dp->dl_stid.sc_file->fi_deleg_file, 1)->nf_file;
@@ -7371,6 +7379,10 @@ static bool open_xor_delegation(struct nfsd4_open *open)
 	/* Did we actually get a delegation? */
 	if (!deleg_is_read(open->op_delegate_type) && !deleg_is_write(open->op_delegate_type))
 		return false;
+	/* A read delegation stateid does not permit WRITE. */
+	if (deleg_is_read(open->op_delegate_type) &&
+	    (open->op_share_access & NFS4_SHARE_ACCESS_WRITE))
+		return false;
 	return true;
 }
 

-- 
2.55.0

