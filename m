Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820229;
	b=StpA1rZAin2sUDpKJRyeq0Jk8IAd8yOWfPbTs/+48gPwTYnVYx8thtI9y8esygUM6Urn
	 gyKQWxY4BSE53oF9oMa4+lVglctGKDSthWuBmxeSsy/UqKL/tRgE6/1/ZkxzA2Qj+TqGS
	 haNDInh3oLqsmFilBpRqVGPAQTRUKiVNMMG86vF1EOs07iRJghr6PvsjAmqNVCjBuV1Zo
	 nvq+yVJ2TcH0UMmM8cN3OELc1+sLEZKHeqjHDRc+Wa1RK1yhch/h8fzbQ5ZzPNHqhkkA5
	 TPyaiHOpc81onEpIsvsZZ+LwWyPqaf4mPrr8pcmS0/1dNaHi5fo38ufLnDNYDT+nQOw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820229;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=bxrLiMapbfHc1EZ+4ADuNXD+VcOTR1takrrVPNDTeA0=;
	b=yCEAlGzswpUf3z7hoBGRUrJOOeS4KRygWzjV2MhsFp+1ur+ZELA8p4pjh/hF/5T89V47
	 vJ35Ai3unnz/iZ596/wbPtpnErd/kxpJZI+KFXsHS2im1iHaneVGKhHsQKFbTnFh4qpvI
	 pIHJSGMepfvNl+bqDUpcucRrVG1NfMaD2MJxLCbHctlFh3/Uz2vAb6Ku59OmV1priN/Sd
	 Hs91IamWnK0okiV7opzEHf1tq/+ELJ5wnJ0fbQA3vFC+wn5aW4fvXzcBjVSRtvxsIh67c
	 y3MdZs7ZPC+bFlK5qEMT/+BPp2EYqMjTqxa3QBdWml1meQ9z0ERhuWDcBFKaSjgQMlA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P31HtERM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 667FB606D838;
	Wed,  4 Nov 2026 19:23:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P31HtERM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C06D31F000C1;
	Wed,  4 Nov 2026 19:23:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820229;
	bh=bxrLiMapbfHc1EZ+4ADuNXD+VcOTR1takrrVPNDTeA0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=P31HtERMFSNol745g3BnGZcUyftsO75M5cryrOhg6uEEbTLO6qd91z1whz/V2YoHZ
	 ZlzF0+NzxGOlzGJPmN3xtmGCNUFfLbt3joPtIH3f++AsuKwEwzdZWf6PdSPxU7A5yK
	 hFlsOXtLhO48r6ueNfnwp0RlYnnSBnRpoiWgq0lskwVIqMMuSuxexcIO+FClliWYpS
	 hoTGOlDLQflfOhdnS0Q3JIK9G3p3uFTRqKXWRJMZ3R4KfowrbaGqQRi07M1QXljwV7
	 th41CQpzl4loprGAQ2TnAnPwUAVWszzRtKlAOT9RVmKV+lhjT8YsGn0BrHVgoiFo6f
	 9SqeE0/BUHJiw==
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
Subject: [PATCH RESEND v2 31/51] proc: don't WARN about a name that is already registered
Date: Wed,  4 Nov 2026 20:23:34 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-31-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2415; i=brauner@kernel.org; h=from:subject:message-id; bh=zKPnydEa7A3MJSKUBbljFnXGgiSfil9PV1OK0LsDT40=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bvz0UbupS+ReqKmx550QBcPIx+fCyiSlZmydoTxvS U2b4Fm+jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIlcZGT4n20a3HVie8QyAeOH +n67d9j9VH0TdtVtZvPnw4Ent+xues3wh797msrH+LVBAu8/HVj4xtelPai56DjDmvc933d/ZL7 3hAsA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_register() WARNs when the directory already has an entry of the
same name and fails the registration. Callers that pick their names
themselves should never get there but some take names from userspace.
pktgen creates a file for each device a writer of "add_device" adds,
named after the device. A device can have any name, including "pgctrl"
or "kpktgend_0", the names of pktgen's own files:

  ip link set lo name pgctrl
  ip link set pgctrl up
  echo "add_device pgctrl" > /proc/net/pktgen/kpktgend_0

  proc_dir_entry 'pktgen/pgctrl' already registered
  WARNING: fs/proc/generic.c:404 at proc_register+0x555/0x8b0, CPU#0: bash/241
  Call Trace:
   proc_create_data+0x9f/0xf0
   pktgen_thread_write+0xd9b/0x1780
   proc_reg_write+0x1c2/0x3c0
   vfs_write+0x1cd/0xfa0

The files of a network namespace belong to the root of its user
namespace and none of this requires a capability. So once pktgen is
loaded an unprivileged user can taint the kernel, or crash it with
panic_on_warn, from namespaces of its own. pktgen itself copes with
the failed registration just fine.

So go back to what proc_register() did before commit 6c2f91e077f1
("proc: use WARN() rather than printk+backtrace") and what
sysfs_warn_dup() does for sysfs: report the name with pr_warn() and
dump the stack. While at it, do that after dropping proc_subdir_lock
instead of printing a backtrace while holding the lock that every
lookup and readdir in procfs needs.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 6c2f91e077f1 ("proc: use WARN() rather than printk+backtrace")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/generic.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index 6ac9c4c13897..9e59796349e1 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -402,9 +402,10 @@ struct proc_dir_entry *proc_register(struct proc_dir_entry *dir,
 	write_lock(&proc_subdir_lock);
 	dp->parent = dir;
 	if (pde_subdir_insert(dir, dp) == false) {
-		WARN(1, "proc_dir_entry '%s/%s' already registered\n",
-		     dir->name, dp->name);
 		write_unlock(&proc_subdir_lock);
+		pr_warn("proc_dir_entry '%s/%s' already registered\n",
+			dir->name, dp->name);
+		dump_stack();
 		goto out_free_inum;
 	}
 	write_unlock(&proc_subdir_lock);

-- 
2.53.0

