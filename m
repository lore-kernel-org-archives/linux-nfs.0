Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5F9E32931E9
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 00:38:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788136736; cv=none; b=rGe+fRJ1dW9jD9/8ctRm48SEkQrIIQTavvmlhcZoWQ1QD2mfUfJTJJlN5wnR71wsmDrC77D9IbGtWAnoXhL8eS1fwgpZ7ZltNlONoeCJnq0e5iA1YjOkD5gZaYD8dykLu1lJwSDIXViZhYFNIqST64PFUI2TjLaQEiVwc9ZpTL4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788136736; c=relaxed/simple;
	bh=JwNIkG3ZBXD+AzbpTJ7LTqc6uS/Lf0D6mI4JcTE9p9o=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=O28GR/zeUiTF8f3hH133YSmyXqYE7U8oL/NcMqnRbukySDja2yUVov6yVzKnNcONQJbCLC+KYJJRq2LtJFq3fFXpQnFMim4Eb2Tq0I2gV26EybxryZrSQEY0IkuDYwSTlb3ac92ABvAsonjpJaGijSfcdmc3+kN5Fzng6im/lQU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fdFXuRA1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fdFXuRA1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 748151F000E9;
	Mon, 31 Aug 2026 00:38:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788136735;
	bh=BPPQeO90hOy+aB5YEgMXndU1UOIVREPLenZhAfgb9Es=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fdFXuRA1Za/RwpkjVa27gys4IEdWh8Ukb4eCLwuPtspy5tiuGZO/PjAyiQZ/Mlby8
	 FTCAjkR0QWGtgoSMJ0uQsQsg9aTYjK1z+bfraEoYLOXdNF4ajIo1zEG6YbY8rPrhOr
	 B8/n8RjVLID/2xcnOsL2D/yGAbr7ME6DksqA8wTBm7RrL47xAjvDKc91yXwsJ497CM
	 jIbioLqIvHmDsGo5gVkcoi7HngtY+FaPKhdZjkqI0JoD65VXNRv1EvTKorAgh9Wj0m
	 QBF3A8HfXfIyHqEVr/TIb7eQyaMXY4uMDVAcoQtp4blvgdqOeqAT6SCq7IHD/U1OTj
	 846oEpi+vkuqA==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 30 Aug 2026 20:38:41 -0400
Subject: [PATCH 4/5] NFSD: Reject an oversized principal hash from nfsdcld
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260830-alemi-v1-4-463f80b9e9a8@kernel.org>
References: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
In-Reply-To: <20260830-alemi-v1-0-463f80b9e9a8@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>, 
 Scott Mayhew <smayhew@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1567; i=cel@kernel.org;
 h=from:subject:message-id; bh=JwNIkG3ZBXD+AzbpTJ7LTqc6uS/Lf0D6mI4JcTE9p9o=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlM0ZGfgDcY1XtQBOXDtdstf6WLW9x8SVlrOee
 z9Bm4MQ6iKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapTNGQAKCRAzarMzb2Z/
 l9yAEACJ2obKFmogZM1qo/X+HnUep/DjCDVNxsfvEKzN+3j55SLmyJ4VPPjP2pX66wSAwzuqaPC
 LI/fMWwesqxKLr+2UzVK81XDGerokNZ91rnUECkBn6RKCAlZI3k2w3efj58FNFfmaba5LEgTnr1
 N2rrSVqQm9VmEvf/FwPpFyq6NuRkqqNd5hOhT8t9gz8t5xENP1hr2qWPRmxJNBbl7tm3rt9YMBS
 3ElYhwnBM2m4H1J6z2r6qtHpiSBhb/HMB+tcnOKvHRqa9eE15CsStaVMNTl9oiZ54VINZfhxngL
 4e+6v4udcNZ+VHXfw7DeD7eQzePRgZ2tfZApHstyB835iH/vvlMtOeS1OnvuWVKqBlKZVHsSQeg
 rhZ+Sb3iFikyVdAN8Ac/NaQmGoMtqLfuOhFNcGqBbIRYV5j4vxwSPwJ3QrdSs67uT9RuVjrDu0P
 NEKf6Z+sdf63yZlXXD58TLutO0YKGSIzzaCBPHmtUCKKMpKep8aNWx+6FxPhNk0SUxZdd49ZMU8
 8qw7v/dkFSYoOGnQQNZIfQtB+0l0vK1dZWqF6jfncRUW6bzw8Qz0W4m7JoeUDBxL4DuZlMR6szq
 hiTdpG93HIdEO0VEn8zFK5Uztncrz0Rik7howOoSZ8FZmOYlAcxDCqfnL4SdUTzp6kZpjfGvQGg
 JVpmI/XZNBS6qYg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

__cld_pipe_inprogress_downcall() takes the principal hash length
from the daemon's GraceStart downcall without checking it against
the cc_princhash payload it describes, which holds at most
SHA256_DIGEST_SIZE bytes. The length is stored verbatim in the
reclaim record, and nfsd4_cld_check_v2() later hands it to memcmp()
against a digest array of SHA256_DIGEST_SIZE bytes on the stack. A
length up to U8_MAX reads past the end of that array, and the stray
bytes can only make the comparison fail, denying the client its
reclaim. The pipe is mode 0600 in rpc_pipefs, so the trigger is a
broken or hostile nfsdcld rather than an unprivileged task.

Reject a length larger than the wire field, as the existing check
on the client name length does.

Fixes: 6ee95d1c8991 ("nfsd: add support for upcall version 2")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4recover.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 999694db9981..8af935ed0c4e 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -730,6 +730,11 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 			name.len = namelen;
 			if (get_user(princhashlen, &ci->cc_princhash.cp_len))
 				return -EFAULT;
+			if (princhashlen > SHA256_DIGEST_SIZE) {
+				dprintk("%s: invalid princhashlen (%u)",
+					__func__, princhashlen);
+				return -EINVAL;
+			}
 			if (princhashlen > 0) {
 				princhashcopy = memdup_user(
 					&ci->cc_princhash.cp_data,

-- 
2.54.0

