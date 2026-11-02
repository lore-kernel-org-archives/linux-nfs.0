Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629681;
	b=ag33JNnzEzM1onGZuZEGjnQzjF9zh6IWxQsLLi+/45HaWrh36AAKXfMcjXgJA8I2T972
	 jxrNpL6kqw9wWLry4lfloBtY405R6HxRVlZQmcDTOOopvIUZTxr/pWCKmemNiFMjTUqR1
	 7NrEocBAVBvzD4XVRXqm9AczNnRnirTELYbaoiYqk2ep24xKSfhQV5di7Ctu/kpXkEp7I
	 jHaCPfo/vZlmi4ipJkEf1l3kDdV8HpwMJgvpvUQEqR1WIv7j+EPpGDPxu8J5Kdm4xvUXy
	 omcwCTAJ2/6eJIoVV+vg65dEEzkxSIjCJcGoq5cd6MdPS1qnPi1r/iq8oqhG96IzPLw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629681;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=x9e4ZuKPIpi8QBo4p8aCvRLGQ76YDcFSkXYxDQ/HDJc=;
	b=g5G+nNS7PS0gJfUYuRLj/j+cLzurmCKA6MvhlyFxuIjL4Lfab8cZjVuM0PfHkJ7e6Xzh
	 t3Q5RL5wgM89AtD+lqtiSiKtg0/cnivvrSV5yc80iJQAEZXWRNrNDmEu9pg3Eh1kQOENS
	 PYTL47/XoLsO50z+ZQNWChvPo6QeHOGeaVVmmYba16ytIXA3PcRy7tZH+zQU5Eg6/KaJ3
	 gsKfkk7fn8kMB1UjEs12QwwNhE2Y6CQXSdcX4qwTrPKOezNGxOUT7aEC4rZAZPV5Ytx0L
	 iw5z9YvLrhAKH9aH6jEqVkbqtQJPCxNcKqnKhyhIVNzBy50Fe989v1AskhiI2+OKrBw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z7jSW8oc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1FC2606F217;
	Mon,  2 Nov 2026 14:28:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z7jSW8oc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1F24E1F00A17;
	Mon,  2 Nov 2026 14:27:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629680;
	bh=x9e4ZuKPIpi8QBo4p8aCvRLGQ76YDcFSkXYxDQ/HDJc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Z7jSW8ocw2GTtsdhy2iLSOSMpWez+vmr7UbhcqFGOJPgV+mfUirasVaGqGjfy1MhC
	 JfdOwZP+NjPjF3axJA25tkHe3FYpmshpGP7JUFL5ycSp9F9xDVUWPTXynOAX7lLDQy
	 lyX77813HhkSilKPJJiaixyUHa1YuUBkrL4nIlzerhARC42GiEhDGVDidxwBdM5Fve
	 2202Lg+45oaSoehyVe/VfbRF4DlEvQXBh0kjqh2jlMLvpzzjhh601Kw2fcyec2y7B8
	 HZR3WDITUZsok4mxLcicXIz+3n6P9tENE705RyDiGEHAZB1hWIT1RX87e64+KLQO9v
	 YjlZGmkXrHfmA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:42 +0100
Subject: [PATCH RFC 27/38] sunrpc: make queue_wait a global wait queue
 again
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
Message-Id: <20261102-work-procfs-bugfixes-v1-27-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
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
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=4395; i=brauner@kernel.org;
 h=from:subject:message-id; bh=WxVX5Tk7+VjiQ4HOwMZ1/ws7cMwoYvJOjs/gK5FWGI4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJPzJJWxrePPaosrlWIRfIIVuzheh1b9qPU0WbiTl
 93hvZ9ERykLgxgXg6yYIotDu0m43HKeis1GmRowc1iZQIYwcHEKwER+1zIyzD56TIlf772HuYFp
 7KHNoXN7XHoLLr75vvzNt5Pt06bJHWL4X7PzL9/h4ru8Jg+dc9RunmidE/k+d//0KxOeSjdxP5o
 awQYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Since commit 552d0e17ea04 ("sunrpc: convert queue_wait from global to
per-cache-detail waitqueue") poll() and epoll queue their waiters for a
channel file on the queue_wait head in struct cache_detail. But the
cache_detail can be freed while its channel file is still open and
waited on.

The procfs channel files of a network namespace are removed when the
namespace goes away. Removing a procfs file waits for the callers that
are in one of its methods right now and then calls ->release on every
file that is still open (cf. close_pdeo()). The waiters that poll() and
epoll left on the head stay queued until their file is really closed.
So:

  sunrpc_exit_net()
  -> ip_map_cache_destroy()
     -> cache_unregister_net()
        -> remove_cache_proc_entries()
           -> proc_remove()      // ->release, the waiters stay queued
     -> cache_destroy_net()      // kfree(cd)

and when poll() returns remove_wait_queue() writes to the freed
cache_detail:

  BUG: KASAN: slab-use-after-free in _raw_spin_lock_irqsave+0x4b/0xa0
  Read of size 1 at addr ff110001131bb570 by task sunrpc-poll-uaf/242
  Call Trace:
   remove_wait_queue+0x22/0x1c0
   poll_freewait+0xc2/0x230
   do_sys_poll+0x9ba/0xd50
   __x64_sys_poll+0x165/0x470
  Freed by task 12:
   kfree+0x267/0x620
   sunrpc_exit_net+0x34/0x80
   ops_undo_list+0x271/0x8d0
   cleanup_net+0x3f3/0x860

Closing an epoll instance that watches the file gets there through
ep_unregister_pollwait() instead.

The channel files of a network namespace belong to the root of its
user namespace and cache_open() doesn't check for a capability. So an
unprivileged user can open the channel file of a namespace of its own
from the outside, poll it and let the namespace die.

Go back to a single static wait queue that never goes away. A wakeup
for one cache wakes the waiters of all caches again but cache_poll()
reports per cache_detail so that's just a spurious wakeup. procfs
should really own the wait queue of its files like kernfs does but
that's nothing for stable.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 552d0e17ea04 ("sunrpc: convert queue_wait from global to per-cache-detail waitqueue")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/sunrpc/cache.h |  1 -
 net/sunrpc/cache.c           | 12 +++++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 2735c332ddb7..bf4fc543e1e5 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -119,7 +119,6 @@ struct cache_detail {
 	struct list_head	requests;
 	struct list_head	readers;
 	spinlock_t		queue_lock;
-	wait_queue_head_t	queue_wait;
 	u64			next_seqno;
 
 	atomic_t		writers;		/* how many time is /channel open */
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1bc04109d213..1ceaea7e01b9 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -404,7 +404,6 @@ void sunrpc_init_cache_detail(struct cache_detail *cd)
 	INIT_LIST_HEAD(&cd->requests);
 	INIT_LIST_HEAD(&cd->readers);
 	spin_lock_init(&cd->queue_lock);
-	init_waitqueue_head(&cd->queue_wait);
 	cd->next_seqno = 1;
 	spin_lock(&cache_list_lock);
 	cd->nextcheck = 0;
@@ -965,13 +964,20 @@ static ssize_t cache_write(struct file *filp, const char __user *buf,
 	return ret;
 }
 
+/*
+ * Not in struct cache_detail: poll and epoll waiters stay queued until
+ * their file is closed, but a channel file in procfs can stay open after
+ * the cache_detail of its dying network namespace has been freed.
+ */
+static DECLARE_WAIT_QUEUE_HEAD(queue_wait);
+
 static __poll_t cache_poll(struct file *filp, poll_table *wait,
 			       struct cache_detail *cd)
 {
 	__poll_t mask;
 	struct cache_reader *rp = filp->private_data;
 
-	poll_wait(filp, &cd->queue_wait, wait);
+	poll_wait(filp, &queue_wait, wait);
 
 	/* alway allow write */
 	mask = EPOLLOUT | EPOLLWRNORM;
@@ -1236,7 +1242,7 @@ static int cache_do_upcall(struct cache_detail *detail, struct cache_head *h)
 	spin_unlock(&detail->queue_lock);
 	if (ret != -EAGAIN && detail->cache_notify)
 		detail->cache_notify(detail, h);
-	wake_up(&detail->queue_wait);
+	wake_up(&queue_wait);
 	if (ret == -EAGAIN) {
 		kfree(buf);
 		kfree(crq);

-- 
2.53.0

