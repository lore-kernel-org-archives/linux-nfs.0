Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793633487;
	b=y6tB8mnD+nx74PJPjfppSgewMl/7ShPXGExXp49Hoiol2nK4g2lf72/lXrxWZg5d7EqN
	 nNXMp51mFKq3lmkGi2HIh18/tyzXFwPWFT4tqftFt/3Mo0+zgLpDP47rbUVMvHpOgiNnj
	 JL4MIO6fhQ9e4y7I6+ur0QTkRYQtQRPUTnFKnq9fFaqX/uSnSHkd6bSBxvMkFfwfV7gBn
	 6kPn7UMo8eRJTt3f/CYVdZaC5BQVtux0JxWuZtrVcYU5UNCmg8PNG0MufhKJaR2ZTs/+7
	 6Fp4HsBtw2RVVIRJr2igPAnXHKy5zyYU430wVIRKrQHxhnJrMJT1u1trbgENw/pF9Cg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793633487;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vwjxO3TYvy6WGJQYdN5saH6B1iVdIocyydf/9B8LfXQ=;
	b=ejap+jFTxjfrt8K3cPiYH+Wdp0fj/4mDAYCxeOF28LTKrYKVUoWAskpO/S6yCjP2TiAa
	 eLhItJU1VWukS132sRSTDD5nRsIfhQZCUlgNoCDemy0YrZU0Asp2aMih8M/4IO0dFEvJs
	 0ACJPyIMrpxhsRLEpoD9gYEGQoe8yXdnSEyzG7GMrnK5e03K18WHYGmaGeH6MYWIJbdkm
	 34LEzJVqv5rnmmWXtglVTIj19/rGRl/7KHY/eRKoJYy5VnPL3+TvrUfkPBbxINRjkZzMB
	 R+AyCSJCIbgJIkPCewXFdz2rwCvvFpgfxnbD76fJ9L9rS17ZqfmBkXXq1vz3CDUNDYA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="UbE/GY/P";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4F9D607228E;
	Mon,  2 Nov 2026 15:31:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=UbE/GY/P
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 89ABC1F00A17;
	Mon,  2 Nov 2026 15:31:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793633486;
	bh=vwjxO3TYvy6WGJQYdN5saH6B1iVdIocyydf/9B8LfXQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=UbE/GY/PYzhi2Fi7si7/s3It7tNz4DO7UQGlprH7NLzpJSufJcUt6S7sLl4ETioTn
	 lSrxhrhtFMtQb6rZpoE6MoG5MG9eu/oVVRZmwnTVdQmH/Uc8YanZxUbAPJ3I9S4O7q
	 z0m2i9CWxWD03GNLvtDJCEzS1ywzTD672wOGOyzXiiTxjSmYm4JDOfioeSmLQa60Ds
	 a3wnZ+yTE9KkhVTKNfGA/bKsony/u5hTU2nvptIrn6VLRSoxE92Hyqh1vP22R1USo3
	 fnoX0h5mvFahCSUZxRECbsbRhCqA2NVJbxVIwTQPsraXYkSxXkM4wzwb15ZC+dp27b
	 y5/kCl5AgK1UA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 16:07:16 +0100
Subject: [PATCH RFC 02/11] l2tp: let procfs own the seq_file of
 /proc/net/pppol2tp
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
Content-Transfer-Encoding: 7bit
Message-Id: <20261102-work-procfs-net-v1-2-982104a4f592@kernel.org>
References: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
In-Reply-To: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1918; i=brauner@kernel.org;
 h=from:subject:message-id; bh=/g5R4n0Ms+FYrKqMM/T6cxyrF8YI/t11/rZZuOTaMss=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9WG78rF41UVcn6s+kRfI/lJTvq/TI+ez8kiHKd3vOn
 QnBrmtYO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYi9oyRYf/NOSUiv50MPlxP
 STf7vX/f6RkVu0Vzktw3n+teH3BIfwcjQ6e+2UWHa43H2pdHS7s1ZT76oqVzw0iU/67rXo/gM16
 nuAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Declare the seq_operations and the size of the iterator state and let
procfs open and free the seq_file. ->proc_open() only takes the
reference to the network namespace now and ->proc_release() drops that
and the references the iterator holds. Reading the file then no longer
holds up its removal.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 net/l2tp/l2tp_ppp.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 4f311d473a64..499e37eb788a 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -1596,21 +1596,17 @@ static const struct seq_operations pppol2tp_seq_ops = {
 	.show		= pppol2tp_seq_show,
 };
 
+/* procfs opened the seq_file and allocated @pd */
 static int pppol2tp_proc_open(struct inode *inode, struct file *file)
 {
-	struct net *net = pde_data(inode);
-	struct pppol2tp_seq_data *pd;
+	struct seq_file *seq = file->private_data;
+	struct pppol2tp_seq_data *pd __maybe_unused = seq->private;
+	struct net *net;
 
-	net = maybe_get_net(net);
+	net = maybe_get_net(pde_data(inode));
 	if (!net)
 		return -ENXIO;
 
-	pd = __seq_open_private(file, &pppol2tp_seq_ops, sizeof(*pd));
-	if (!pd) {
-		put_net(net);
-		return -ENOMEM;
-	}
-
 #ifdef CONFIG_NET_NS
 	pd->p.net = net;
 	netns_tracker_alloc(net, &pd->p.ns_tracker, GFP_KERNEL);
@@ -1633,13 +1629,13 @@ static int pppol2tp_proc_release(struct inode *inode, struct file *file)
 #else
 	put_net(&init_net);
 #endif
-	return seq_release_private(inode, file);
+	return 0;
 }
 
 static const struct proc_ops pppol2tp_proc_ops = {
+	.proc_seq_ops	= &pppol2tp_seq_ops,
+	.proc_state_size = sizeof(struct pppol2tp_seq_data),
 	.proc_open	= pppol2tp_proc_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
 	.proc_release	= pppol2tp_proc_release,
 };
 

-- 
2.53.0

