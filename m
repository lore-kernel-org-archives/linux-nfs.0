Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820392;
	b=AIsuhc1+JmKMjdjd/+H6n47YouyLRo6gqvAFFrE7FHU/gY4gyoLp6X+MJJTaXgf+XaWB
	 zMXrk+tP2FLvdaXGXhuRSX7jyu9OWkPFyr03kT7Zp4seJeGLmF6ulsEzuTickOdyV6ut5
	 stCmyMpKgEaDpyZfzIiuoxqZc+o/HX8bB/+J4uiQSIPG/legcuzKW09BD8/HcvERfCRi4
	 XRPsmmVSoLzPMKROefa0xtI9i91YmnEWsqFMQEUP2lA4i052Zj4DK1MEZusfE4txSX1HK
	 Dy6ceRlfPhe1zymwIOqjFK1yCrsKcUrVBZrVKTT6eOcmeEoF31ef20STtHbKgcmKIyA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820392;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=KzL9ZYHhLfhD3DOSumSkk0Gb2fITAVoHxCDSq8u5ZOY=;
	b=1NgyDDd58F9Whp7XTuYwdBbtM6L2eAkA1/ECqDCxbfMp5U4/AHl45sAo38q34C5RyfWW
	 rRDq3iujDEh3yhZiI1puRNlb988JbvDmIheGinTwF4DuQu2bYUiNMwBxGyd+Pz7Zi03rN
	 UqwkmL0yh7a91Q98J0MV8/gNGt7+8TqxyiuTiOpEPeIREzf1LjmYIDotiLLhyvrDpu9C4
	 e2SpQA4vvtbeZGzKXmqm9fVxm7gFG/4raQ0GaH2mDAIOljL5XZ1sOLdw5hbHu5svmkpVy
	 zEfmWYq3BP2C4mcIEMy/hdYBr0k0Yc9q2GXROdjLS4lLneDpOgd5vB3q7vqAcCvnn6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="OZmY/n0G";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B61646072F80;
	Wed,  4 Nov 2026 19:26:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OZmY/n0G
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2A02B1F00A18;
	Wed,  4 Nov 2026 19:26:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820391;
	bh=KzL9ZYHhLfhD3DOSumSkk0Gb2fITAVoHxCDSq8u5ZOY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=OZmY/n0GXXd/waY5eO8CY5Onurst3JuvNiiWNIXcNO2ZuOFKp902BomvRAZeqhqov
	 gVBa7tGTm8eGOA6FIqPzs+gKGb0cET9WaFFoJDGhKN+qiibaBT/bgrlsrKWepwCufy
	 7xbZtg/lGvVf2Z6lEc3/gKQcCopkPYa2/MYuxGe78rFjMFuwi6sASyH6Jok98Wg17F
	 cJ/qQVE/skC9zQGR9GKwMIm//f3mEfB8/4bBi4VeRM6Lw8lfYzjOtO7fBSGQY1KnwG
	 yl+O33qpdvuGjSLboBidD8ILci0GW1gs7UGQ/cvvcbiCIna8PYu+uszQ30CIehYMR+
	 tDP/eU01ohS5g==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH RESEND v2 42/51] powerpc/pseries: bound the lengths in the ofdt property parser
Date: Wed,  4 Nov 2026 20:26:17 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-42-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4036; i=brauner@kernel.org; h=from:subject:message-id; bh=1x5L5ygLqoH4QYrbzxN55G88uXTL5wNw5UNSw5/l5lQ=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bvx/eMaUE0I+8x7uP2vLHsplqPp8Uf8cnbKLyd/ve zkpum1k6ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjIciOGfwpWqRcLVdK6Yk+U 7Mjin33JpmbO+9ppHJaBzs+t3kx9ZcXwV37rzQebpE0czPNr1/Zo75BRluja0J3FW2zd03c/onQ XAwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

The commands for /proc/powerpc/ofdt that carry properties, "add_node",
"add_property" and "update_property", can make the parser read past the
buffer they were copied into:

(1) do_update_property() computes the end of the buffer after
    parse_node() moved buf past the phandle. So the end is off by the
    length of the phandle string, which can be padded with zeroes, and
    parse_next_property() accepts a value that reaches that far past
    the command. new_property() then copies those bytes into the
    property, which everyone can read in /proc/device-tree.

(2) parse_next_property() parses the length with simple_strtoul() into
    an int and only rejects -1. A length above INT_MAX turns negative,
    tmp += *length moves backwards and passes the check against the
    end, so *tmp is read up to 2G in front of the buffer.

(3) Updating "slb-size" or "ibm,slb-size" reads an int from the value
    whatever its length.

Compute the end before parsing the phandle, reject lengths that don't
fit into an int or into what is left of the buffer, and only take the
slb size from a value that holds one. The file is root-only and
refused under lockdown but the parser still shouldn't read past its
input.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Fixes: 610d91511f99 ("[PATCH] powerpc: Add support for changing properties from userspace")
Fixes: 46db2f86a3b2 ("powerpc/pseries: Fix to handle slb resize across migration")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/reconfig.c | 18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index 5a0c9c0b6253..b543afbc1efb 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -114,6 +114,7 @@ static void release_prop_list(const struct property *prop)
 static char * parse_next_property(char *buf, char *end, char **name, int *length,
 				  unsigned char **value)
 {
+	unsigned long len;
 	char *tmp;
 
 	*name = buf;
@@ -133,13 +134,13 @@ static char * parse_next_property(char *buf, char *end, char **name, int *length
 	}
 
 	/* now we're on the length */
-	*length = -1;
-	*length = simple_strtoul(tmp, &tmp, 10);
-	if (*length == -1) {
+	len = simple_strtoul(tmp, &tmp, 10);
+	if (len > INT_MAX) {
 		printk(KERN_ERR "property parse failed in %s at line %d\n",
 		       __func__, __LINE__);
 		return NULL;
 	}
+	*length = len;
 	if (*tmp != ' ' || ++tmp >= end) {
 		printk(KERN_ERR "property parse failed in %s at line %d\n",
 		       __func__, __LINE__);
@@ -148,13 +149,13 @@ static char * parse_next_property(char *buf, char *end, char **name, int *length
 
 	/* now we're on the value */
 	*value = tmp;
-	tmp += *length;
-	if (tmp > end) {
+	if (len > end - tmp) {
 		printk(KERN_ERR "property parse failed in %s at line %d\n",
 		       __func__, __LINE__);
 		return NULL;
 	}
-	else if (tmp < end && *tmp != ' ' && *tmp != '\0') {
+	tmp += len;
+	if (tmp < end && *tmp != ' ' && *tmp != '\0') {
 		printk(KERN_ERR "property parse failed in %s at line %d\n",
 		       __func__, __LINE__);
 		return NULL;
@@ -320,8 +321,8 @@ static int do_update_property(char *buf, size_t bufsize)
 	char *name, *end, *next_prop;
 	int length;
 	struct property *newprop;
-	buf = parse_node(buf, bufsize, &np);
 	end = buf + bufsize;
+	buf = parse_node(buf, bufsize, &np);
 
 	if (!np)
 		return -ENODEV;
@@ -337,7 +338,8 @@ static int do_update_property(char *buf, size_t bufsize)
 	if (!newprop)
 		return -ENOMEM;
 
-	if (!strcmp(name, "slb-size") || !strcmp(name, "ibm,slb-size"))
+	if ((!strcmp(name, "slb-size") || !strcmp(name, "ibm,slb-size")) &&
+	    length >= (int)sizeof(int))
 		slb_set_size(*(int *)value);
 
 	return of_update_property(np, newprop);

-- 
2.53.0

