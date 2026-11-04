Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793819863;
	b=FHkC2W2J8lj0k1NlUMn2qSOiZvB9PcxjW7uhIQkucxEN3BGyEUdG4pkIRDQG1JcnQnOe
	 8S5Q1srgkta3QNgxtBwkXavm1kcojdRdSRlp3BUD7D6kqOhAy7fpjW14wLp3xLfBpTgIo
	 6CGG4cXtxYWSo/CK+dR3yibi9pWlTTY62SMGDu0JK8/Cg30vfT9d7RwQjksvFMtFcIq0j
	 dDKajssf7UaDPmouAI9u4gnydYXXLxgeTHIqDHXM8wxkZu9TM+lvsBVZi6Q3ZSt3CJYqQ
	 AvvyaoCxnpy7B6P09ohAXeUuzXxJS3YcPKCdX3+p3AvREMyppXtvqIgOLfoob0w06zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793819863;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=7dKsu59FtDy8aNyG4WRUkN7aPYhsNBybpSNJpPGyZ1Y=;
	b=bBMhSArOp+yNGAbH779cUKVRahCZzdq7oDNNiNoioyvWuycTpcY8GLMRMCfN7Kh13c0G
	 zQiCNuBU2ChbZf8CUmvDe46KzyOyfkiv8Swp2+3J/4P8i81c+g3ja9n4KAF965S/pO7S/
	 G2KxItTQbZvvdc0VNnz/PjlNd2JpUnZcNMp6gwK3yg62RwLaLHK3KOxHmQC1EttOHZ4JQ
	 2VRMWxqmOGTo7+Aqt4fh38IgBqwYgaRqzLpmtY3JDitPI9eZpQ6IUlCUeL1KfaiBjW1Pp
	 lNNkdHfphJz6QLH6dtRLv+x0J/11flEj/KKBTMjY9c6YrO9pr5uB17Ewnqf34FnKwFw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I09Dgc3W;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1948A606EE82;
	Wed,  4 Nov 2026 19:17:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I09Dgc3W
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CEF121F00A02;
	Wed,  4 Nov 2026 19:17:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793819862;
	bh=7dKsu59FtDy8aNyG4WRUkN7aPYhsNBybpSNJpPGyZ1Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=I09Dgc3WahkVUkdHZb1ultk0YMkOb02PK1qI6zEJbOi7/+V3zq8fq+cWRfZX05NQG
	 2lA2rqFRv/45g4bPULWMQHffdRExyDxzArc/hYgSBx4eO5MffKe3yy8p97CR46mmmZ
	 9dDXzJEWztjf6EaVEqFVKoidDZJ+7rTAReCBc9+dsxygtzA4VX74eEUMjD1bcfkFu3
	 QYaB8uEysRHzykLP06EUs/1ZqunIBWNogzs/SWlT+hZAEg08JSMeZHXTmY93feNFRf
	 2ZEizdSTdr3U+mIMp0z1pvTgsP0C80x+AxPAiukAaNUo0JSRGMr1Yf0WgHtW4okH6U
	 zKMPB78QEQ4oA==
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
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 06/51] powerpc/pseries: put the node that the ofdt property commands look up
Date: Wed,  4 Nov 2026 20:17:28 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-6-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1735; i=brauner@kernel.org; h=from:subject:message-id; bh=9GgvRCMv4/Dc1Z942cy3A7/ul6cTW5I084eAKnASIT8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bry04VhwqY6ktsHfDTVnr+b4bPJgfc+0lt/P01dek tuWdbdCRykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwERavjAy7FnwPn/GgnMaE2ec 2t9e+OuRtkX+5sUTRSbzyRQ8OMAzexYjw5M736flveC7KnfK7e6vd6+v/AiwDEi4qz5l7VpJx5c MnYwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

parse_node() looks the node up with of_find_node_by_phandle(), which
returns it with a reference, and do_add_property(),
do_remove_property() and do_update_property() never put that
reference. Every property command written to /proc/powerpc/ofdt leaks
one. Put it when the command is done.

Fixes: 610d91511f99 ("[PATCH] powerpc: Add support for changing properties from userspace")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/reconfig.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/reconfig.c b/arch/powerpc/platforms/pseries/reconfig.c
index 18e3f1a036e3..5a0c9c0b6253 100644
--- a/arch/powerpc/platforms/pseries/reconfig.c
+++ b/arch/powerpc/platforms/pseries/reconfig.c
@@ -271,8 +271,8 @@ static char *parse_node(char *buf, size_t bufsize, struct device_node **npp)
 
 static int do_add_property(char *buf, size_t bufsize)
 {
+	struct device_node *np __free(device_node) = NULL;
 	struct property *prop = NULL;
-	struct device_node *np;
 	unsigned char *value;
 	char *name, *end;
 	int length;
@@ -296,7 +296,7 @@ static int do_add_property(char *buf, size_t bufsize)
 
 static int do_remove_property(char *buf, size_t bufsize)
 {
-	struct device_node *np;
+	struct device_node *np __free(device_node) = NULL;
 	char *tmp;
 	buf = parse_node(buf, bufsize, &np);
 
@@ -315,7 +315,7 @@ static int do_remove_property(char *buf, size_t bufsize)
 
 static int do_update_property(char *buf, size_t bufsize)
 {
-	struct device_node *np;
+	struct device_node *np __free(device_node) = NULL;
 	unsigned char *value;
 	char *name, *end, *next_prop;
 	int length;

-- 
2.53.0

