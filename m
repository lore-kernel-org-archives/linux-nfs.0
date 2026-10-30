Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374227;
	b=bp75TaowolkGQoOxXvcSgNktWhP50K3rRIWzQGBRo/dyjZefChVUQAEgKlC7XV9iZsmh
	 Xx/Ak+/+rzr12FnaaAFhz/U3kFW9PiV1zlKezoUGbh3+01Jr7u/0b5DxTGM282fWUThUu
	 ptkeGpzEtYUZWEUufUk/DQjw4aj2PztyO64knvUq0ET3iofNXKTxr15awRwN1/iwdSjTH
	 kUSVYfVUfmOl4JXpEVzXlniD60XLvWo9kbrUrUJn8E4+HKjpjlI2U14IFJX5feyET0+IO
	 M2ntMrOwBgFKp6FjiXHHCA2k23ICza5IZSa0sLehrKV1cUFF90eQ63GbWvNdOPqad9Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374227;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
	b=44Y9gg6l+AGkgrM9248clsUZEhOa18RC1j8d0rlKTy6c81z1koRn4bXQ27SIcQ5jpkLI
	 8iddIMPmNjgMvLnJNDp/RjPGEIEft+0yFfT0npWhzeL37ISeMsewHIEduCJtTmwNSv2Z6
	 n5aiftleHdWAfFSztN+q+Hi6rLCLjgfTTHuxCjrdXHT+Epo5qRDvzeTIowUoWF6EzBhkI
	 UgCvtKRvExgf8l9heuKOCEjpqC+86mZSyNx4+AJflQc2fH2gUPRvVhkSs5VJJ2fct7hAt
	 vi1CUZqfmYOYm+KVuk7fhEM3kuw4rbOVjY1+wZozRHlnc3oO9shle4JN5JSCZSWn8Jw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=jfAjaWNg;
	arc=none smtp.remote-ip=209.85.161.47
Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 226A3606A31E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 226A3606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=jfAjaWNg
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-6d68de53053so397149eaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374226; x=1793979026; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=jfAjaWNgH9fGrPw+1OrRCl8SN5MOG/d5OWY+ojB0VU2ZwC8SWN74LZlAMy7C36h+G8
         y7+7vfP3ykm1vetE29RjQmfIOab+UPKfKY0qwbIpn+qkICOOF2Gl37NNSKmHF/U5U4Ys
         iNFOTWsgCON4OOrLxZ+GupWJBX/ouL8l2+sJDuIsnpHAo1SvT9nIKsuaP3KGZEQFLvem
         rgon3hYgAm56RDItqs5b572Y9t/jOPiRev3pFJ6RvD+D4lT9yxo4v3PynlFYPKOExvuj
         bu+qXyfk2pdKtBR4laR2Rw/IVqPk6g5yOE0OwE5wF17IW8H7U6y3wyFQJqQrpmGtMIEH
         N2lQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374226; x=1793979026;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=kCkvYfSpv5meezm4S7EoTqsEQXJyrxV1WFdOSy4aup4=;
        b=w4V9s65zeA6k73oLPcGadrtFCPKDtCuk65Z33kFSol2J7FFV5DfVEFRfoPykMfvN6z
         1FcqDtdnDuMsEYv17U2N0I2XDUBrJADNsv2IZzQspLhMWJQ5YQtXwXfslwRkkfvNvJyu
         pueZZpfWLqwb0CyqXw+5Ys92gpynFJjW8h6QCcV6w5CZR8EW0LI0WbBoYNVCXvK42EXN
         wNBvWWQj70Ldsx6akgcQNNaFoGiKtiNNZiFt+y1dEFVUxYr7anbhkvqdnFptCexr+uwA
         THZtnXGSyNGvm4U2dq3HQoXl+ZQvzuD4px9irr4tQGxcGAItUlpAZvDq1egyvVcuNS6n
         2AIg==
X-Gm-Message-State: AFq9FYJIymEZtNFCcqwLMSIfTAngYam50JL3AWJkg1HXyGj4Vdw6pBEs
	X5idBS5XK74v/RxvadEoK8pYTJVMFmvq6/yyjaL8KvKDrwDRMunCS2mkNiMk5bROwD0=
X-Gm-Gg: AYBFou2rHpzlzBtnrVsN8VMv8KF1SIgN/nEqQ0g6FTSLJDU8rjF81d9QAuY8BskH7Js
	Yqz3HTarJMewvO4lczoxZGp1QfZIUq+ZbLmHRMLku812OvW67Ihvo+ankcH4p+e8WDayaIC3yV5
	lnttz6wzi8AaTMs6iWJc4qaMBWw94riF1DBMNVftd1VbHNwqVCE8yrZLI7uGpIHXRo2dvGedpRV
	kCdnNViZG8/aSD0UwQ6nGHQU3WxGwAsAmvQ9wJUhsl0BSB4z1YcS+WF+GjftpAc0J3wph205/GT
	gC5tEwJYo0a/dKkx2EXe36gOBO8nvxKf9BXVyK6lYzqXtzZf5gurX/14DegaM/ihBtLQC7K9/TX
	grMAjVXGJXAuKSRyIXk4rVbAnzYyVBoOHCtZfXj4jbnpg4J7AJMjzvkvGWeso7ZmzAw4GrxuDK3
	13O3QqpvrUowFeAyEI1SDK3ZKS3PTf8a/xGg+tnotQBa+oGS5LuuBQO2FhaAYiVTR8mvwkZS7sz
	bktzrP0tbYDJREHS5mo6QC0tfpWc4I3t2V/aeIxovXRowr41NFuFm6ZqFa6lxXU337RY324OHRv
	Ws+v5o1uhrSu5OMO7xR3ci7GJ0uxKEvuNnOtkaWKkcIzl2GAkCk9iwX71DVCsOCxcfws7zbTNYk
	NtqxXhNRfAcrgV8RXp6V0DFeYFVEJ3AQ=
X-Received: by 2002:a05:6808:23cf:b0:53a:e153:e8e7 with SMTP id 5614622812f47-5640dd8a159mr1923810b6e.44.1793374225986;
        Fri, 30 Oct 2026 08:30:25 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:25 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/6] NFSv4: add a tracepoint for bulk CB_LAYOUTRECALL replies
Date: Fri, 30 Oct 2026 11:30:17 -0400
Message-ID: <1cdcfef536459c717d7acb3b1f5571a07724b249.1793373378.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

There is a tracepoint for the reply to a CB_LAYOUTRECALL of a file, but
none for a recall by fsid or of all layouts.  Add
nfs4_cb_layoutrecall_bulk, which records the recall type, the fsid, and
whether the client replied NFS4ERR_DELAY or NFS4ERR_NOMATCHING_LAYOUT.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c |  7 +++++-
 fs/nfs/nfs4trace.h     | 49 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9d836cb72e78..722bb5475a48 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -352,8 +352,13 @@ __be32 nfs4_callback_layoutrecall(void *argp, void *resp,
 	struct cb_layoutrecallargs *args = argp;
 	u32 res = NFS4ERR_OP_NOT_IN_SESSION;
 
-	if (cps->clp)
+	if (cps->clp) {
 		res = do_callback_layoutrecall(cps->clp, args, cps);
+		if (args->cbl_recall_type != RETURN_FILE)
+			trace_nfs4_cb_layoutrecall_bulk(cps->clp,
+							args->cbl_recall_type,
+							&args->cbl_fsid, -res);
+	}
 	return cpu_to_be32(res);
 }
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..e5abc186ecc4 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1571,6 +1571,55 @@ TRACE_EVENT(nfs4_cb_layoutrecall_file,
 		)
 );
 
+TRACE_DEFINE_ENUM(RETURN_FSID);
+TRACE_DEFINE_ENUM(RETURN_ALL);
+
+#define show_layoutrecall_type(type) \
+	__print_symbolic(type, \
+		{ RETURN_FSID,	"FSID" }, \
+		{ RETURN_ALL,	"ALL" })
+
+TRACE_EVENT(nfs4_cb_layoutrecall_bulk,
+		TP_PROTO(
+			const struct nfs_client *clp,
+			u32 recall_type,
+			const struct nfs_fsid *fsid,
+			int error
+		),
+
+		TP_ARGS(clp, recall_type, fsid, error),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, error)
+			__field(u32, recall_type)
+			__field(u64, fsid_major)
+			__field(u64, fsid_minor)
+			__string(dstaddr, clp ? clp->cl_hostname : "unknown")
+		),
+
+		TP_fast_assign(
+			__entry->error = error < 0 ? -error : 0;
+			__entry->recall_type = recall_type;
+			if (recall_type == RETURN_FSID) {
+				__entry->fsid_major = fsid->major;
+				__entry->fsid_minor = fsid->minor;
+			} else {
+				__entry->fsid_major = 0;
+				__entry->fsid_minor = 0;
+			}
+			__assign_str(dstaddr);
+		),
+
+		TP_printk(
+			"error=%ld (%s) type=%s fsid=%llx:%llx dstaddr=%s",
+			-__entry->error,
+			show_nfs4_status(__entry->error),
+			show_layoutrecall_type(__entry->recall_type),
+			__entry->fsid_major, __entry->fsid_minor,
+			__get_str(dstaddr)
+		)
+);
+
 #define show_stateid_type(type) \
 	__print_symbolic(type, \
 		{ NFS4_INVALID_STATEID_TYPE,	"INVALID" }, \
-- 
2.53.0

