Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=54.207.22.56
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793777307;
	b=WUU3aMEb8HRuNC+TnhFfLo/2g+uc6wrUCOJB0g2C6QE4VVptvLDUvqGwCmkFA4SZvX8l
	 n/Bk7M+AbdXybfdrF2L+E4eO63GpqmmYDfSzb4bg/0RN9PpXy14lf2k0KE+LyR/k1veG+
	 9qt6ECxVIW87AYpcZ+Yc8oW/Nxdd+dY4La7ooTjEiCq8VL2+TOiIZekuOuAqr9AFnyPyt
	 5H/toErPQZlWwlmhYWAIVY2Bgw2zZMzdTWYtflUunZsrq6RlQ7uKORQFnp+wR/HYcqzSr
	 Z7keaqR0UHz04Q8qYsNXZ5ei7c8sUzMNFuDpt7vFPxKLi14DqG54OIvTvx/Yk1Xg3UQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793777307;
	h=DMARC-Filter:DKIM-Signature:X-QQ-mid:X-QQ-Originating-IP:Received:
	 X-QQ-SSF:X-QQ-GoodBg:X-BIZMAIL-ID:From:To:Cc:Subject:Date:Message-Id:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding:X-QQ-SENDSIZE:
	 Feedback-ID:X-QQ-XMAILINFO:X-QQ-XMRINFO:X-QQ-RECHKSPAM;
	bh=be9bczZx+EM646VLei+i+HtAlIAfcJVJs1cobE3VByI=;
	b=WUsQI1ltJowBB66V12PVi8744RHdgoV3HlHvAzwE7W/rCotruYFVB43nNPKQVgPd2yDA
	 fkXmObbDezwDNaVvl9AHGrquEZEAbzldZn+oBpe4hiH78oF60BTqUpiuk7wXkq512RWuz
	 FJoRuWeaVUrAQYUHuch6QQrP6xXK/3D69RLSstc300I07NKBXhv0aovZsMhEwpSMgxgkr
	 0hd5oHh+TuNU7uuft7Aut67ETfEXOGRS4enx90FlG/vsBzS70FlUX3uUkA9tm/7u6X0gG
	 rQJwCScLbC0iy9gJ1whvu2YVc+fC8MoKZdBAE9ey+nxoSp6hZdT1iUw5HAHAVhFmV4g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=uniontech.com;
	spf=pass smtp.mailfrom=uniontech.com;
	dkim=pass header.d=uniontech.com header.i=@uniontech.com header.a=rsa-sha256 header.s=onoh2408 header.b=RMXlVEDA;
	arc=none smtp.remote-ip=54.207.22.56
Received: from smtpbgbr2.qq.com (smtpbgbr2.qq.com [54.207.22.56])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C4A9606A32C
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 07:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C4A9606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=uniontech.com header.i=@uniontech.com header.a=rsa-sha256 header.s=onoh2408 header.b=RMXlVEDA
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uniontech.com;
	s=onoh2408; t=1793777212;
	bh=be9bczZx+EM646VLei+i+HtAlIAfcJVJs1cobE3VByI=;
	h=From:To:Subject:Date:Message-Id:MIME-Version;
	b=RMXlVEDAeXe+saKn+pnRgbEwChtiYP4EA0aiFurCqWTvAScVhc50k5xlH2lbgO0ko
	 JnN+c7U7vd/vGyi8gCyRmkY+1lV+9ZAeAqL9VZKAlJec1y6aIfGS/HRSOau5mS0AJx
	 C+FrRi4gluvIL91hdPnieL6dh9G7XNaXCb+0gTEI=
X-QQ-mid: zesmtpgz7t1793777206tae1c1011
X-QQ-Originating-IP: ZCUOh3SoeJ9o4vnSxrYKvJwgDnFLWXvWBsFW/lf0OS8=
Received: from localhost.localdomain ( [1.202.39.170])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Wed, 04 Nov 2026 15:25:32 +0800 (CST)
X-QQ-SSF: 0000000000000000000000000000000
X-QQ-GoodBg: 1
X-BIZMAIL-ID: 1049222982562815418
From: Xue Haolin <xuehaolin@uniontech.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com,
	jlayton@kernel.org,
	smayhew@redhat.com
Subject: [PATCH] fsloc: fix crash on an invalid entry in a locations list
Date: Wed,  4 Nov 2026 15:25:21 +0800
Message-Id: <20261104072521.636114-1-xuehaolin@uniontech.com>
X-Mailer: git-send-email 2.20.1
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
X-QQ-SENDSIZE: 520
Feedback-ID: zesmtpgz:uniontech.com:qybglogicsvrgz:qybglogicsvrgz6b-0
X-QQ-XMAILINFO: NQkHVi/RNHOFclGNELvgOcm4UJEtakiGB8phvpilHWdest5UDFJ+lClP
	7ma9QCxVCUzasf7x53pqrGSyScnsq8P0glj68JCCQBs/su8XImKR7llDgNJ57qSC01MwxKI
	OII0WPjPOefRhv70ZzV1JlzOxeZxCUVpZWe3HWropIYZhXJKQks1UdzrHRSUq8uZyTM9cNr
	SY23B/P1VUHn7VkfjcOhDApY5mn0osS4+4Du0TbJW9BIgSb5mh5nIblf8681wWy5fWKuTnR
	/pKKM32jdGDjNpNlfKX/CSEvodGJD1aZcwpZ7iO1gddEN5ZcVNrPcx9Oaa5qdSPxmTfdQ5I
	QvTF3bVCa80HFLv+VqGDiaMPygQ4PRQxyGM0DtcMZG7Zx85j7Hz1eT8w/Y0+H/Xo1fvKOPS
	OQRLZwF8mChZlF3EL1/DDifwDI9UTbyOK3dsXbl8iunoyLRP5s8GTMRhWFwvRxGX0Dpvdnt
	jGLW9cV1tVI9hvrc4SadVBRmp91w5rer9qPaVxxMwObRmHGuhKeFcGoToFpPtW0nqELjCNB
	ERv9xFyTZyBSJiyeQFD3Zox8zV4mv9y6MHrq+jvMjsFztF3s3vDAutnRkmuMtb0r5+xagsk
	j7EEvT2HQK55weE6dbtI6M+be+Z498SIG+jeR/R0/RaShBx99OEmSoPLi0oqe+S6qO0aoXE
	ElzBEc653l2O1/MFnVrcvVGxLYLjzQS4q2Jmdf+LSUi5t9DfyaiSOGbCQ7O4HvojmEmfjVw
	WbLjxlt7vvRHBb9Q/TWaKAjE5D0SZUgdUBv94EvW/7ySigLjwgKAPfkxe5qIRUXoi57rRgw
	DrfQ+ORIrxkN+mJrLxWaJPWmQv+F7cA32C8Yc2OMvXsMy3XdFDCcKFMzn3+jnqNnqbPk0R9
	jN1tdI2sxWMishEtXujNvmXpswag+6EoNZ882tco+yHmmdk2e0STG0cn/MM+qyF7u394Ah0
	objBByeXYWd10KYkC/CQckxsZ0FLtD9Qjo9NVlmUQLKZRZORHPTGkofKe6dpE1bPXZMrh4n
	kgeEcQlnjVNj1/53pW3V6+rGoqIM7NKQRfIbBRG1R5kn2PxTM8DhjpUIOcoy0=
X-QQ-XMRINFO: OWPUhxQsoeAVwkVaQIEGSKwwgKCxK/fD5g==
X-QQ-RECHKSPAM: 0

From: Haolin Xue <xuehaolin@uniontech.com>

parse_list() stores each parsed entry in res->h_mp[i] using the loop
index, but only increments res->h_num for entries that pass validation.
An entry that is rejected and skipped with "continue" therefore leaves
h_mp[i] unset while i has already moved on, so a later valid entry is
stored above the slot that h_num accounts for.  Every consumer walks
h_mp[0] .. h_mp[h_num - 1] (replicas_print(), release_replicas() and
write_fsloc()), so one skipped entry makes them dereference an
uninitialized element of the malloc()ed servers structure.

With a malformed "refer=" or "replicas=" option in /etc/exports, e.g.

	/export *(refer=/export:/export@server2)

where the first location is missing its host, rpc.mountd dereferences
heap garbage while it (re)builds the export cache: it either takes a
SIGSEGV or aborts in free() from release_replicas().  A typo in the
exports file should at worst produce a warning, not kill the daemon and
lose the whole export, valid locations included.

Number the array slots independently so that h_mp[] is always dense and
h_num always matches it.  Valid lists are unaffected: FSLOC_MAX_LIST
still bounds the number of entries kept, and rejected entries are still
reported with the same L_WARNING.

Add a tests/ regression case that feeds malformed lists to
replicas_lookup() and checks that the surviving locations are parsed
with a dense h_mp[].

Fixes: ec75fd41fcf2 ("Add missing fsloc.[ch] files - oops.")
Signed-off-by: Haolin Xue <xuehaolin@uniontech.com>
---
 support/export/fsloc.c   |   6 +-
 tests/Makefile.am        |  11 ++-
 tests/fsloc_parse_test.c | 152 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+), 6 deletions(-)
 create mode 100644 tests/fsloc_parse_test.c

diff --git a/support/export/fsloc.c b/support/export/fsloc.c
index 1b869b6..a9e5a86 100644
--- a/support/export/fsloc.c
+++ b/support/export/fsloc.c
@@ -82,7 +82,7 @@ static struct servers *method_stub(char *key)
  */
 static struct servers *parse_list(char **list)
 {
-	int i;
+	int i, n;
 	struct servers *res;
 	struct mount_point *mp;
 	char *cp;
@@ -93,7 +93,7 @@ static struct servers *parse_list(char **list)
 	res->h_num = 0;
 
 	/* parse each of the answers in sucession. */
-	for (i=0; list[i] && i<FSLOC_MAX_LIST; i++) {
+	for (i = 0, n = 0; list[i] && n < FSLOC_MAX_LIST; i++) {
 		mp = calloc(1, sizeof(struct mount_point));
 		if (!mp) {
 			release_replicas(res);
@@ -105,7 +105,7 @@ static struct servers *parse_list(char **list)
 			free(mp);
 			continue; /* XXX Need better error handling */
 		}
-		res->h_mp[i] = mp;
+		res->h_mp[n++] = mp;
 		res->h_num++;
 		mp->h_path = strndup(list[i], cp - list[i]);
 		cp++;
diff --git a/tests/Makefile.am b/tests/Makefile.am
index a199ce0..c536568 100644
--- a/tests/Makefile.am
+++ b/tests/Makefile.am
@@ -1,15 +1,20 @@
 ## Process this file with automake to produce Makefile.in
 
-check_PROGRAMS = statdb_dump
+check_PROGRAMS = statdb_dump fsloc_parse_test
 statdb_dump_SOURCES = statdb_dump.c
 
 statdb_dump_LDADD = ../support/nfs/.libs/libnfs.a \
 		    ../support/nsm/libnsm.a \
 		    ../support/misc/libmisc.a $(LIBCAP)
 
+fsloc_parse_test_SOURCES = fsloc_parse_test.c
+fsloc_parse_test_LDADD = ../support/export/libexport.a \
+			 ../support/nfs/.libs/libnfs.a \
+			 ../support/misc/libmisc.a $(LIBCAP)
+
 SUBDIRS = nsm_client
 
 MAINTAINERCLEANFILES = Makefile.in
 
-TESTS = t0001-statd-basic-mon-unmon.sh
-EXTRA_DIST = test-lib.sh $(TESTS)
+TESTS = t0001-statd-basic-mon-unmon.sh fsloc_parse_test
+EXTRA_DIST = test-lib.sh t0001-statd-basic-mon-unmon.sh
diff --git a/tests/fsloc_parse_test.c b/tests/fsloc_parse_test.c
new file mode 100644
index 0000000..347858f
--- /dev/null
+++ b/tests/fsloc_parse_test.c
@@ -0,0 +1,152 @@
+/*
+ * fsloc_parse_test.c -- regression test for parse_list() in fsloc.c
+ *
+ * parse_list() used to index res->h_mp[] with the loop counter while
+ * res->h_num only counted the entries that passed validation.  A rejected
+ * entry (one without an "@host", or not starting with '/') therefore left a
+ * hole in h_mp[] that h_num did not account for, and every consumer walks
+ * h_mp[0] .. h_mp[h_num - 1]: replicas_print() dereferenced the uninitialized
+ * slot and release_replicas() free()d it, taking rpc.mountd down on a mere
+ * typo in a "refer=" / "replicas=" list in /etc/exports.  This test feeds
+ * such lists to replicas_lookup() and checks that the valid entries survive
+ * with a dense, correctly numbered h_mp[].
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor,
+ * Boston, MA 02110-1301, USA.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include "exportfs.h"
+#include "fsloc.h"
+
+#define MAX_LIST 64
+
+static int failures;
+
+static void
+check_list(const char *data, int expected_num, const char *const expected[])
+{
+	struct servers *servers;
+	int i;
+
+	/* replicas_lookup() internally prints the list, so a leftover hole in
+	 * h_mp[] makes the process die here rather than return. */
+	servers = replicas_lookup(FSLOC_REFER, (char *)data);
+	if (!servers) {
+		fprintf(stderr, "FAIL: replicas_lookup(\"%s\") returned NULL\n",
+			data);
+		failures++;
+		return;
+	}
+
+	if (servers->h_num != expected_num) {
+		fprintf(stderr, "FAIL: \"%s\": expected %d entries, got %d\n",
+			data, expected_num, servers->h_num);
+		failures++;
+	}
+
+	for (i = 0; i < expected_num && i < servers->h_num; i++) {
+		char buf[512];
+		int n = snprintf(buf, sizeof(buf), "%s:%s",
+				 servers->h_mp[i]->h_host,
+				 servers->h_mp[i]->h_path);
+
+		if (n < 0 || (size_t)n >= sizeof(buf) ||
+		    strcmp(buf, expected[i]) != 0) {
+			fprintf(stderr, "FAIL: \"%s\": entry %d is \"%s\", expected \"%s\"\n",
+				data, i, buf, expected[i]);
+			failures++;
+		}
+	}
+
+	release_replicas(servers);
+}
+
+static void
+check_rejected(const char *data)
+{
+	check_list(data, 0, NULL);
+}
+
+int
+main(void)
+{
+	/* Invalid entry first: the whole point of the fix. */
+	static const char *const two_with_leading_bad[] = { "server2:/export" };
+	/* Invalid entry in the middle. */
+	static const char *const two_around_bad[] = {
+		"server1:/export", "server3:/export"
+	};
+	/* Nothing invalid: valid lists must be parsed as before. */
+	static const char *const two_valid[] = {
+		"server1:/export", "server2:/export"
+	};
+	/* Invalid entry last: worked before too, guard against regressions. */
+	static const char *const one_with_trailing_bad[] = { "server1:/export" };
+
+	char many[8192];
+	char entries[FSLOC_MAX_LIST][32];
+	char *expected[MAX_LIST];
+	int i;
+
+	/* An invalid entry must not take the daemon down, and the valid
+	 * entries on either side of it must be kept. */
+	check_list("/export:/export@server2", 1, two_with_leading_bad);
+	check_list("/export@server1:/export:/export@server3", 2, two_around_bad);
+	check_list("/export@server1:/export@server2", 2, two_valid);
+	check_list("/export@server1:/export", 1, one_with_trailing_bad);
+
+	/* Entirely invalid lists simply yield no locations. */
+	check_rejected("/export");
+	check_rejected("garbage");
+
+	/* The 40-entry FSLOC_MAX_LIST bound still applies, and it counts the
+	 * entries that are kept, not the ones that were scanned. */
+	many[0] = '\0';
+	for (i = 0; i < FSLOC_MAX_LIST + 1; i++) {
+		char entry[32];
+		if (i)
+			strcat(many, ":");
+		snprintf(entry, sizeof(entry), "/export@server%d", i + 1);
+		strcat(many, entry);
+	}
+	for (i = 0; i < FSLOC_MAX_LIST; i++) {
+		snprintf(entries[i], sizeof(entries[i]), "server%d:/export", i + 1);
+		expected[i] = entries[i];
+	}
+	check_list(many, FSLOC_MAX_LIST, (const char *const *)expected);
+
+	/* One rejected entry in front of an over-long list: the rejected entry
+	 * must not push a valid entry out of the array (the old code kept
+	 * server1..server39 here). */
+	snprintf(many, sizeof(many), "/export");
+	for (i = 0; i < FSLOC_MAX_LIST + 5; i++) {
+		char entry[32];
+		snprintf(entry, sizeof(entry), ":/export@server%d", i + 1);
+		strcat(many, entry);
+	}
+	check_list(many, FSLOC_MAX_LIST, (const char *const *)expected);
+
+	if (failures) {
+		fprintf(stderr, "fsloc_parse_test: %d check(s) failed\n", failures);
+		return 1;
+	}
+
+	printf("fsloc_parse_test: all checks passed\n");
+	return 0;
+}
