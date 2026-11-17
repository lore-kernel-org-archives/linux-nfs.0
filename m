Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=18.194.254.142
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794885132;
	b=GdZSoxjMLzYfnetqX5Pfh3oEA42Wp6BTw0rW285RGiR/hzpR0IHeymEp9ipBECJzP/WZ
	 V1eyN7oOTR7jizam0LyAdte8Bor1FtJL3n2hotUASv8VGTPr9iDVzW/PD5aeAA0o4oNNR
	 Hu7R0Q8oyOj5yNftrxnN9kzZx1A+MyhQPpelB50PXcy1oXRI1FgZxbve1HgZv3zZ0JxmU
	 bC/Gd5BiTVntGydsTvew2MH1iR67MSkZwfmsFvV3CFeCKH69lXbL+NGSee0Mpj2+UGR1o
	 zoEMRbLpScbnzG8vJOQCZidh20bAAFc75SrugYUhIr42t63WmxzyJ+i1h691ONp18dw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794885132;
	h=DMARC-Filter:DKIM-Signature:X-QQ-mid:X-QQ-Originating-IP:Received:
	 X-QQ-SSF:X-QQ-GoodBg:X-BIZMAIL-ID:From:To:Cc:Subject:Date:Message-Id:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding:X-QQ-SENDSIZE:
	 Feedback-ID:X-QQ-XMAILINFO:X-QQ-XMRINFO:X-QQ-RECHKSPAM;
	bh=BJ556ecJR4Jd8JuWQ1rM7zpdNzlHdcT1E+BDUM2gyOo=;
	b=yOjom5zHcdLNOKbG1BlZV2M2KUUtgqBOYCzRWHk2+RdvJfiHw+GJH4xuJ3ihRaXvSsyx
	 9G6ch87A3cdz0pmBbhfZRuEbJdYFUGOuZ1B4aQ4ZwVJed1XdjjQllHyQ7gUJS7v6b9OhQ
	 WNA55kqc7cQMFLJztGPpWzn2jKSONDLzC+gCKlb+h0eRs9v8oH9TlYl0bpX6YGnMtfy50
	 iD8tif3pruOX6mBTw45lbApOgNyJDNQMHM6Jj0n1JmFZarNeioAQ3+PbqU0vyTKqv0I7h
	 8l8JrDl4+n3r0hxqk/pTKlSWSrQyOwXmCG7IRwlY/Wkh9YbB8CpCHRj5ubif3c9SEdQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=uniontech.com;
	spf=pass smtp.mailfrom=uniontech.com;
	dkim=pass header.d=uniontech.com header.i=@uniontech.com header.a=rsa-sha256 header.s=onoh2408 header.b=PIllbhmr;
	arc=none smtp.remote-ip=18.194.254.142
Received: from smtpbgeu2.qq.com (smtpbgeu2.qq.com [18.194.254.142])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EBD6606A323
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 03:12:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4EBD6606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=uniontech.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=uniontech.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=uniontech.com header.i=@uniontech.com header.a=rsa-sha256 header.s=onoh2408 header.b=PIllbhmr
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=uniontech.com;
	s=onoh2408; t=1794885108;
	bh=BJ556ecJR4Jd8JuWQ1rM7zpdNzlHdcT1E+BDUM2gyOo=;
	h=From:To:Subject:Date:Message-Id:MIME-Version;
	b=PIllbhmrmtg1lmEX24JoVg5f8wnIQevVnfLVjCkcsIexsJdTLDS6GAzbikPQSmi1+
	 5ZVyxFLisFtM+UdwsQEH2rXiBQfZ75YrxuGiqceG3Cp6n0oNrG5z6HqA+NZiDvn4u8
	 JTCN/k5Rh+OmaWBbseb6RMTcWcwxqht10AA4bgVE=
X-QQ-mid: esmtpsz18t1794885104tb6fad94a
X-QQ-Originating-IP: 25MguXpvtI2AgLPtzZCztXSfAog0cMKUOSnpT28dVZ4=
Received: from localhost.localdomain ( [1.202.39.170])
	by bizesmtp.qq.com (ESMTP) with 
	id ; Tue, 17 Nov 2026 11:11:38 +0800 (CST)
X-QQ-SSF: 0000000000000000000000000000000
X-QQ-GoodBg: 1
X-BIZMAIL-ID: 17942564023683854382
From: Haolin Xue <xuehaolin@uniontech.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [PATCH v2] fsloc: fix crash on an invalid entry in a locations list
Date: Tue, 17 Nov 2026 11:11:32 +0800
Message-Id: <20261117031132.258227-1-xuehaolin@uniontech.com>
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
Feedback-ID: esmtpsz:uniontech.com:qybglogicsvrgz:qybglogicsvrgz6b-0
X-QQ-XMAILINFO: M5z4lLHHBhdazGABNUlEMfO7KMFbIZzQG+TG604qJqLUnoe94cELnwVu
	yz3kao1htKnfe6/mBxAS6isK0diLaqUo+XbsgxN1r8kib5nIHFBErhOkxM8WqXI7OVAGLf3
	9lOyl5smTQj4mmRj1XPiKdfAF3fY2hOaDlN2X9LE2LWVNNkW9fYwnmR/gruTSm/J1WelogA
	jkSf3jvmlJ661cZoppSsswxC9iFaKjcepTuZLMiYrgy65tzjhNHCYDoAgdVSg7t9RAuv7oa
	gqOVA2R5xL2u807DA5xkVxACBb4+KsZ53gxlnsLArZWREMTKCWH9DWJ6PvRfA4u/7nBWYUz
	MeNW2tRpkMdf8lp2+loF6Scoy9TxQwirUCdiIcv4K4vyKs9YcblCbgYDIdKjKCIVYEtdKDh
	4Aw/Q7s2OPEiPKM/ZY7lizqlCe2FHoUE6Wgdg7P86A9GepwokxAjddhUhYsrSn1aKLuG47Y
	0LebOXqvh/puy4l6kvjiR13MTaiWV66Iht1Qw+WOKCB/gjPsOFyGPGWNjlTbFUQFsqQQzS8
	e7NfqsuRaSjVzIyLrIF3KLxWthkAyXBfQxfrwKtRKe6Ni3QVEQHjHSvbVUrKSeC9zpq2z3r
	G8ulVK14gtDQkw5+GarBkAxKLl6n3JtsTJWy52l2uU53/ysrtO5sTZCeTmydnYyPWdDUZew
	foApomCFl7lM3Fm+1jVxqS7VkW5D3FYiwC0/p3pU5V1fcqMdh0DB2NoFt2E3+5GQwFQ966t
	DC9ldXY5NBsNr61LMhsPx5oerViohI+K1CeXPraBu+qYPg0Hb04FkTQ7psftLt/QBsYROr/
	eRZHvjk/Km4ZEyxFl/p6Nd2ItNciV2/euzzDUUALdJFn1GFVRAJmq1qZ0hG0LHA6osLxdAC
	l3fW8u5kPHVKtKfS/rHN9ueh0inw2EAlzc39GGNkZBSX5x2zV3N6OHA3ucvcpqcSu/CO0IH
	MqycAxzyxAt+bbYyXsJhAzWnTWmEGiLyuwxkuLbnwcHFBMXqo2Re4NsDn2ARTSeSwA8zsg5
	oOg7M7fDfSuep7Fn4ScwK3YSFHbIVZY7v60909w5giTEjtAdEc
X-QQ-XMRINFO: MSVp+SPm3vtSI1QTLgDHQqIV1w2oNKDqfg==
X-QQ-RECHKSPAM: 0

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
Changes in v2:
- Rebased onto the current upstream master (c1f521c4, tag
  nfs-utils-3-1-2.rc4).  support/export/fsloc.c is untouched upstream since
  v1 was posted, so that hunk re-applies verbatim (blob 1b869b60).
- Resolved one conflict, in tests/Makefile.am: upstream gained a new test
  (t0003-get-maintainer.sh, commit bbb50905, 2026-11-13) after v1 was
  posted.  The rebased patch keeps t0003 in TESTS and appends
  fsloc_parse_test, and lists the shell test scripts explicitly in
  EXTRA_DIST so that the built fsloc_parse_test binary is not distributed;
  v1 had replaced the whole $(TESTS) list, which would have dropped t0003
  from the tarball.
- No change to the fix or to the test's expectations.

Verified on this base: "make check" passes 3/3
(t0001-statd-basic-mon-unmon.sh, t0003-get-maintainer.sh,
fsloc_parse_test); restoring only the old fsloc.c makes
fsloc_parse_test abort with SIGABRT ("double free or corruption (out)").

 support/export/fsloc.c   |   6 +-
 tests/Makefile.am        |  11 ++-
 tests/fsloc_parse_test.c | 152 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 163 insertions(+), 6 deletions(-)
 create mode 100644 tests/fsloc_parse_test.c

diff --git a/support/export/fsloc.c b/support/export/fsloc.c
index 1b869b60..a9e5a86b 100644
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
index 851b88ac..29a639dd 100644
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
 
-TESTS = t0001-statd-basic-mon-unmon.sh t0003-get-maintainer.sh
-EXTRA_DIST = test-lib.sh $(TESTS)
+TESTS = t0001-statd-basic-mon-unmon.sh t0003-get-maintainer.sh fsloc_parse_test
+EXTRA_DIST = test-lib.sh t0001-statd-basic-mon-unmon.sh t0003-get-maintainer.sh
diff --git a/tests/fsloc_parse_test.c b/tests/fsloc_parse_test.c
new file mode 100644
index 00000000..347858fc
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
-- 
2.43.0

