Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793883360;
	b=X1q48c49GJRMjUAi+wIutBnzs077jkruGVnkuzWf81Nt/wu7Kqu47KAIvKMJjWv9JBAu
	 iKCIIbBBURlm501OwcvrogK56qdOsAElJU43yx+ipbG9hG6SAX1fuKIolKX3OvoYo0Se6
	 2wAQrJTrc525wdFg6pJyFM6elmETN1J7N/6UcwD+gf8CQMTfXCIc3LCrgPS4dCzd7zOzc
	 vy5fc5oQFc/4TxjY5cFOgsXHbxs6Fq5F+HML+zXE1pukFUtLgpoAqlUi9nqs2P7RrdFAL
	 /h5Kh2ACnf/Cq0SZx2E4S/HakyN7YIgPyVpOi4g/RUSRAOXbeRV60n9HHoxW5t3ivnQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793883360;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spam-Flag:X-Spam-Level:X-Spamd-Result:X-Spam-Score;
	bh=cmUgot10we4d03XqL3f7g9G8JJVHefvFl9Pm7WwDa7c=;
	b=Y/gMkq9ezHbQmBNRgTYu/ZVNMl8bNis+U+/TO3mZ/vqOILpvPaJeQzDaBv8gKFt+iF7D
	 cN6BIY9tvN/xQ+n/cPDGALLZ+4vURRU1Cz9Lrb47PdDBLJl+kFxkWes0ZyHaEh8eHskOf
	 CNtae+lwyqAczJ1j0lhhI1EUGdT4PChbWYp/lcS1t4oMU+X+eHBODSBguE/ODWgap4uZy
	 4znrlGJUUnNp38OPW9sIb1t2Gioy9pRZOiGz8uoz6Ha8CEfXct7bkhpQXuvtHtED+vMIT
	 Zk51fBfp0Va3Jibvk1R8IFs/Oh0AAKxsYM18WE6ceHqdBqtD3Y4gjuQQVLeZ9s1atHw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=HMq2PGgc;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=MNxFmIWW;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=HMq2PGgc;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=MNxFmIWW;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AED4606A329;
	Thu,  5 Nov 2026 12:55:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7AED4606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=HMq2PGgc;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=MNxFmIWW;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=HMq2PGgc;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=MNxFmIWW
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id A593F21E32;
	Thu,  5 Nov 2026 12:55:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793883357; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cmUgot10we4d03XqL3f7g9G8JJVHefvFl9Pm7WwDa7c=;
	b=HMq2PGgctUwaIqMWa/t6KS8Y0eDcx5+iVAbPBEmlA4XLOKQTFUHYY3Wu2G9HFi2gsM87lD
	aMzBxa/v0FwGnVsOPESaie+6I8l5/g4k60NYU2DibVe12MrjUAc1fkTQmxmfgcgcng/l+U
	h4BfEyEohAE+lhFRUtA1oPBHFGrAOjE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793883357;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cmUgot10we4d03XqL3f7g9G8JJVHefvFl9Pm7WwDa7c=;
	b=MNxFmIWW2W0N1wEahhCRtu1bRho1DiR+JlZKUGHHI6elu6vobHwCbHYra5eCjH34Mdn1Y0
	kStFvwQIy0XlegCA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793883357; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cmUgot10we4d03XqL3f7g9G8JJVHefvFl9Pm7WwDa7c=;
	b=HMq2PGgctUwaIqMWa/t6KS8Y0eDcx5+iVAbPBEmlA4XLOKQTFUHYY3Wu2G9HFi2gsM87lD
	aMzBxa/v0FwGnVsOPESaie+6I8l5/g4k60NYU2DibVe12MrjUAc1fkTQmxmfgcgcng/l+U
	h4BfEyEohAE+lhFRUtA1oPBHFGrAOjE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793883357;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=cmUgot10we4d03XqL3f7g9G8JJVHefvFl9Pm7WwDa7c=;
	b=MNxFmIWW2W0N1wEahhCRtu1bRho1DiR+JlZKUGHHI6elu6vobHwCbHYra5eCjH34Mdn1Y0
	kStFvwQIy0XlegCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6652B133F6;
	Thu,  5 Nov 2026 12:55:57 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 7NjCD9187Gp+RAAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 05 Nov 2026 12:55:57 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id E76F9B6F2; Thu, 05 Nov 2026 13:55:56 +0100 (CET)
Date: Thu, 5 Nov 2026 13:55:56 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, 
	Linus Torvalds <torvalds@linux-foundation.org>, Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
	Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Eric Dumazet <edumazet@kernel.org>, Thomas Gleixner <tglx@kernel.org>, 
	Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
	Greg Kroah-Hartman <gregkh@suse.de>, Joel Granados <joel.granados@kernel.org>, 
	Kees Cook <kees@kernel.org>, Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-acpi@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
	linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	netdev@vger.kernel.org, ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
	coreteam@netfilter.org, kexec@lists.infradead.org, linux-pci@vger.kernel.org, 
	linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
	ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
	linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org, 
	linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org, 
	linux-sh@vger.kernel.org, linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
	sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org, 
	linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net, 
	Takashi Iwai <tiwai@suse.de>, linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
	linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org, 
	Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
Subject: Re: [PATCH RFC 35/38] proc: sysctl: don't hold the tables while
 readdir copies to userspace
Message-ID: <ntnca5ndnjaoi7bvfh346zek2jphi4kfmaxv7yd4bqfrfcwjl6@2wdnnptu4igg>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
 <20261102-work-procfs-bugfixes-v1-35-59422ed3e465@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261102-work-procfs-bugfixes-v1-35-59422ed3e465@kernel.org>
X-Spam-Flag: NO
X-Spam-Level: 
X-Spamd-Result: default: False [-11.30 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	RCVD_COUNT_THREE(0.00)[3];
	TO_MATCH_ENVRCPT_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RL63fqwwx8ot6gmekemcs76f9d)];
	RCVD_TLS_LAST(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCPT_COUNT_GT_50(0.00)[60];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -11.30

On Mon 02-11-26 15:21:50, Christian Brauner wrote:
> proc_sys_readdir() holds the directory's table for the whole readdir
> and the table of each entry while dir_emit() copies its name to
> userspace. Unregistering a table waits until nobody uses it anymore. So
> a getdents64() whose buffer faults for as long as it wants keeps
> unregister_sysctl_table() waiting, just like a stalled read() does.
> Listing /proc/sys/net/ipv6/conf/<dev>/ that way holds up the removal of
> the device under RTNL.
> 
> So don't take any table into use for a listing. A header counts what
> refers to its memory, the inodes made for it, and unregistering doesn't
> wait for those. readdir takes one of those references on the entry it
> is at instead, which keeps the header around and nothing else. Under
> sysctl_lock, where unregistering erases an entry, it finds the entry,
> copies its name and mode, follows a link to the entry it stands for and
> pins that. Then it looks the dentry up, creates the inode if there is
> none, which checks for itself under sysctl_lock that the table is still
> registered, and emits the entry with nothing held at all. The next
> entry is the first live one after that name, which is where a listing
> resumes between calls since "proc: sysctl: resume readdir after the
> last name it returned" anyway. kernfs_fop_readdir() and
> proc_readdir_de() work the same way, a reference on the entry and the
> lock only to find the next one.
> 
> While the entry is still registered its node is still in the tree and
> the next one is right behind it, like kernfs_dir_next_pos() continues
> from the node it holds. Only once it went away, and to resume, is the
> next entry found by name. That's one trip through sysctl_lock per entry
> like before, and the link entries of /proc/sys/net no longer take two
> more. The directory isn't
> taken into use either, an entry keeps its directory registered while
> it is used and readdir looks at the directory under the lock. So the
> dots don't wait for anything, a directory that went away lists them and
> then fails with -ENOENT. A seek to an arbitrary position counts the
> entries from the start like before, one trip per entry.
> 
> Fixes: 77b14db502cb ("[PATCH] sysctl: reimplement the sysctl proc support")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

So I didn't really carefully check all the details but overall this looks
sane to me. Just one thing that was confusing me is: Why is sysctl_dirent
separate from sysctl_cursor? Wouldn't it be more logical for sysctl_cursor
itself to start what it needs to pin the entry it wants to restart from?

								Honza

> ---
>  fs/proc/proc_sysctl.c | 307 +++++++++++++++++++++++++++-----------------------
>  1 file changed, 166 insertions(+), 141 deletions(-)
> 
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index a1242247f492..0b7a1e487ed6 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -91,6 +91,8 @@ static void drop_sysctl_table(struct ctl_table_header *header);
>  static int sysctl_follow_link(struct ctl_table_header **phead,
>  	const struct ctl_table **pentry);
>  static int insert_links(struct ctl_table_header *head);
> +static struct ctl_table_set *lookup_header_set(struct ctl_table_root *root);
> +static struct ctl_dir *xlate_dir(struct ctl_table_set *set, struct ctl_dir *dir);
>  static void put_links(struct ctl_table_header *header);
>  
>  static void sysctl_print_dir(struct ctl_dir *dir)
> @@ -367,86 +369,97 @@ static const struct ctl_table *lookup_entry(struct ctl_table_header **phead,
>  	return entry;
>  }
>  
> -static struct ctl_node *first_usable_entry(struct rb_node *node)
> -{
> -	struct ctl_node *ctl_node;
> +/*
> + * What readdir takes along for an entry between the trips through
> + * sysctl_lock: the header pinned, which keeps its memory and nothing else,
> + * the entry, its name and mode. For a link the header and entry are the
> + * ones it stands for in the caller's set.
> + */
> +struct sysctl_dirent {
> +	struct ctl_table_header *head;
> +	const struct ctl_table *table;
> +	struct ctl_node *node;		/* the entry's node in the directory, NULL for a link */
> +	ino_t ino;
> +	unsigned int type;
> +	umode_t mode;
> +	bool skip;
> +	int len;
> +	char name[NAME_MAX + 1];
> +};
>  
> -	for (;node; node = rb_next(node)) {
> -		ctl_node = rb_entry(node, struct ctl_node, node);
> -		if (use_table(ctl_node->header))
> -			return ctl_node;
> -	}
> -	return NULL;
> +/* A reference on the memory of @head, like an inode made for it holds. */
> +static void sysctl_pin(struct ctl_table_header *head)
> +{
> +	lockdep_assert_held(&sysctl_lock);
> +	head->count++;
>  }
>  
> -static void first_entry(struct ctl_dir *dir,
> -	struct ctl_table_header **phead, const struct ctl_table **pentry)
> +static void sysctl_unpin(struct ctl_table_header *head)
>  {
> -	struct ctl_table_header *head = NULL;
> -	const struct ctl_table *entry = NULL;
> -	struct ctl_node *ctl_node;
> -
> -	spin_lock(&sysctl_lock);
> -	ctl_node = first_usable_entry(rb_first(&dir->root));
> -	spin_unlock(&sysctl_lock);
> -	if (ctl_node) {
> -		head = ctl_node->header;
> -		entry = &head->ctl_table[ctl_node - head->node];
> -	}
> -	*phead = head;
> -	*pentry = entry;
> +	lockdep_assert_held(&sysctl_lock);
> +	if (!--head->count)
> +		kfree_rcu(head, rcu);
>  }
>  
> -static void next_entry(struct ctl_table_header **phead, const struct ctl_table **pentry)
> +/* the first entry from @node on whose table isn't being unregistered */
> +static struct ctl_node *first_live_entry(struct rb_node *node)
>  {
> -	struct ctl_table_header *head = *phead;
> -	const struct ctl_table *entry = *pentry;
> -	struct ctl_node *ctl_node = &head->node[entry - head->ctl_table];
> -
> -	spin_lock(&sysctl_lock);
> -	unuse_table(head);
> +	struct ctl_node *ctl_node;
>  
> -	ctl_node = first_usable_entry(rb_next(&ctl_node->node));
> -	spin_unlock(&sysctl_lock);
> -	head = NULL;
> -	if (ctl_node) {
> -		head = ctl_node->header;
> -		entry = &head->ctl_table[ctl_node - head->node];
> +	lockdep_assert_held(&sysctl_lock);
> +	for (; node; node = rb_next(node)) {
> +		ctl_node = rb_entry(node, struct ctl_node, node);
> +		if (!ctl_node->header->unregistering)
> +			return ctl_node;
>  	}
> -	*phead = head;
> -	*pentry = entry;
> +	return NULL;
>  }
>  
>  /*
> - * The first usable entry of @dir after @name, or the first one at all for a
> - * NULL @name. The entries are sorted by name, so that is where a listing
> - * resumes when entries in front of it came or went in between. -ENOENT if
> - * the directory is being unregistered.
> + * Fill @d with the entry of @dir behind the one it holds, letting go of that
> + * one, or with the first live entry after @name, or the first one at all for
> + * a NULL @name. While the entry @d holds is still registered its node is
> + * still in the tree and the next one is right behind it. Once it is gone the
> + * entries are found by name, they are sorted by it, so that is also where a
> + * listing resumes when entries in front of it came or went in between.
> + * 1 with the next entry pinned in @d, 0 at the end of the directory and
> + * -ENOENT once @dir itself is being unregistered.
> + *
> + * Everything that reads the tables happens under sysctl_lock, where an entry
> + * is erased when it is unregistered, since nothing holds the tables in use.
>   */
> -static int entry_after(struct ctl_dir *dir, const char *name, int namelen,
> -		       struct ctl_table_header **phead,
> -		       const struct ctl_table **pentry)
> +static int sysctl_dir_next(struct ctl_dir *dir, struct sysctl_dirent *d,
> +			   const char *name, int namelen)
>  {
> -	struct ctl_table_header *head = NULL;
> -	const struct ctl_table *entry = NULL;
>  	struct rb_node *node, *after = NULL;
> +	struct ctl_table_header *head;
> +	const struct ctl_table *entry;
>  	struct ctl_node *ctl_node;
> +	bool by_name = true;
> +	int ret = 0;
>  
>  	spin_lock(&sysctl_lock);
> +	if (d->head) {
> +		if (d->node && !d->head->unregistering) {
> +			after = rb_next(&d->node->node);
> +			by_name = false;
> +		}
> +		sysctl_unpin(d->head);
> +		d->head = NULL;
> +	}
>  	if (unlikely(dir->header.unregistering)) {
> -		spin_unlock(&sysctl_lock);
> -		return -ENOENT;
> +		ret = -ENOENT;
> +		goto out;
>  	}
> -	if (!name) {
> +	if (!by_name) {
> +		/* behind the entry @d held */
> +	} else if (!name) {
>  		after = rb_first(&dir->root);
>  	} else for (node = dir->root.rb_node; node;) {
> -		const struct ctl_table *table;
> -		struct ctl_table_header *h;
> -
>  		ctl_node = rb_entry(node, struct ctl_node, node);
> -		h = ctl_node->header;
> -		table = &h->ctl_table[ctl_node - h->node];
> -		if (namecmp(table->procname, strlen(table->procname),
> +		head = ctl_node->header;
> +		entry = &head->ctl_table[ctl_node - head->node];
> +		if (namecmp(entry->procname, strlen(entry->procname),
>  			    name, namelen) > 0) {
>  			after = node;
>  			node = node->rb_left;
> @@ -454,15 +467,56 @@ static int entry_after(struct ctl_dir *dir, const char *name, int namelen,
>  			node = node->rb_right;
>  		}
>  	}
> -	ctl_node = first_usable_entry(after);
> -	spin_unlock(&sysctl_lock);
> -	if (ctl_node) {
> -		head = ctl_node->header;
> -		entry = &head->ctl_table[ctl_node - head->node];
> +	ctl_node = first_live_entry(after);
> +	if (!ctl_node)
> +		goto out;
> +	head = ctl_node->header;
> +	entry = &head->ctl_table[ctl_node - head->node];
> +
> +	d->len = strlen(entry->procname);
> +	if (d->len > NAME_MAX) {
> +		ret = -ENAMETOOLONG;
> +		goto out;
>  	}
> -	*phead = head;
> -	*pentry = entry;
> -	return 0;
> +	memcpy(d->name, entry->procname, d->len);
> +	d->mode = entry->mode;
> +	d->skip = false;
> +	d->node = ctl_node;
> +	if (unlikely(S_ISLNK(entry->mode))) {
> +		/* the entry it stands for in the caller's set, or nothing */
> +		struct ctl_table_root *root = entry->data;
> +		struct ctl_table_set *set = lookup_header_set(root);
> +		struct ctl_dir *xdir = xlate_dir(set, head->parent);
> +		struct ctl_table_header *xhead = NULL;
> +		const struct ctl_table *xentry = NULL;
> +
> +		if (!IS_ERR(xdir))
> +			xentry = find_entry(&xhead, xdir, d->name, d->len);
> +		if (!xentry || xhead->unregistering) {
> +			d->skip = true;
> +		} else {
> +			head = xhead;
> +			entry = xentry;
> +		}
> +		d->node = NULL;
> +	}
> +	sysctl_pin(head);
> +	d->head = head;
> +	d->table = entry;
> +	ret = 1;
> +out:
> +	spin_unlock(&sysctl_lock);
> +	return ret;
> +}
> +
> +static void sysctl_dir_done(struct sysctl_dirent *d)
> +{
> +	if (!d->head)
> +		return;
> +	spin_lock(&sysctl_lock);
> +	sysctl_unpin(d->head);
> +	spin_unlock(&sysctl_lock);
> +	d->head = NULL;
>  }
>  
>  /*
> @@ -765,29 +819,29 @@ static void sysctl_cursor_set(struct file *file, const char *name, int len,
>  	memcpy(cursor->name, name, len);
>  }
>  
> -static bool proc_sys_fill_cache(struct file *file,
> -				struct dir_context *ctx,
> -				struct ctl_table_header *head,
> -				const struct ctl_table *table)
> +/*
> + * The inode number and type of the entry @d holds, instantiating its dentry
> + * if there is none. Needs the header pinned, proc_sys_make_inode() checks
> + * for itself that the table is still registered.
> + */
> +static int proc_sys_fill_dirent(struct file *file, struct sysctl_dirent *d)
>  {
>  	struct dentry *child, *dir = file->f_path.dentry;
>  	struct inode *inode;
>  	struct qstr qname;
> -	ino_t ino = 0;
> -	unsigned type = DT_UNKNOWN;
>  
> -	qname.name = table->procname;
> -	qname.len  = strlen(table->procname);
> +	qname.name = d->name;
> +	qname.len  = d->len;
>  	qname.hash = full_name_hash(dir, qname.name, qname.len);
>  
>  	child = d_lookup(dir, &qname);
>  	if (!child) {
>  		child = d_alloc_parallel(dir, &qname);
>  		if (IS_ERR(child))
> -			return false;
> +			return PTR_ERR(child);
>  		if (d_in_lookup(child)) {
>  			struct dentry *res;
> -			inode = proc_sys_make_inode(dir->d_sb, head, table);
> +			inode = proc_sys_make_inode(dir->d_sb, d->head, d->table);
>  			res = d_splice_alias_ops(inode, child,
>  						 &proc_sys_dentry_operations);
>  			d_lookup_done(child);
> @@ -795,79 +849,41 @@ static bool proc_sys_fill_cache(struct file *file,
>  				dput(child);
>  
>  				if (IS_ERR(res))
> -					return false;
> +					return PTR_ERR(res);
>  
>  				child = res;
>  			}
>  		}
>  	}
>  	inode = d_inode(child);
> -	ino  = inode->i_ino;
> -	type = inode->i_mode >> 12;
> +	d->ino = inode->i_ino;
> +	d->type = inode->i_mode >> 12;
>  	dput(child);
> -	return dir_emit(ctx, qname.name, qname.len, ino, type);
> -}
> -
> -static bool proc_sys_link_fill_cache(struct file *file,
> -				    struct dir_context *ctx,
> -				    struct ctl_table_header *head,
> -				    const struct ctl_table *table)
> -{
> -	bool ret = true;
> -
> -	head = sysctl_head_grab(head);
> -	if (IS_ERR(head))
> -		return false;
> -
> -	/* It is not an error if we can not follow the link ignore it */
> -	if (sysctl_follow_link(&head, &table))
> -		goto out;
> -
> -	ret = proc_sys_fill_cache(file, ctx, head, table);
> -out:
> -	sysctl_head_finish(head);
> -	return ret;
> -}
> -
> -static int scan(struct ctl_table_header *head, const struct ctl_table *table,
> -		unsigned long *pos, struct file *file,
> -		struct dir_context *ctx)
> -{
> -	bool res;
> -
> -	if ((*pos)++ < ctx->pos)
> -		return true;
> -
> -	if (unlikely(S_ISLNK(table->mode)))
> -		res = proc_sys_link_fill_cache(file, ctx, head, table);
> -	else
> -		res = proc_sys_fill_cache(file, ctx, head, table);
> -
> -	if (res) {
> -		ctx->pos = *pos;
> -		sysctl_cursor_set(file, table->procname, strlen(table->procname),
> -				  ctx->pos);
> -	}
> -
> -	return res;
> +	return 0;
>  }
>  
> +/*
> + * Unregistering a table waits until nobody uses it anymore and a copy to
> + * userspace can take as long as userspace wants. So a listing doesn't take
> + * any table into use. It pins the memory of the entry it is at, finds the
> + * next one under sysctl_lock and emits with nothing held, like
> + * kernfs_fop_readdir() and proc_readdir_de() do. Between calls a listing
> + * resumes after the name of the last entry it emitted.
> + */
>  static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
>  {
> -	struct ctl_table_header *head = grab_header(file_inode(file));
> +	struct ctl_table_header *head = PROC_I(file_inode(file))->sysctl;
>  	struct sysctl_cursor *cursor = file->private_data;
> -	struct ctl_table_header *h = NULL;
> -	const struct ctl_table *entry;
> +	struct sysctl_dirent d = {};
>  	struct ctl_dir *ctl_dir;
> -	unsigned long pos;
> -
> -	if (IS_ERR(head))
> -		return PTR_ERR(head);
> +	int err;
>  
> +	if (!head)
> +		head = &sysctl_table_root.default_set.dir.header;
>  	ctl_dir = container_of(head, struct ctl_dir, header);
>  
>  	if (!dir_emit_dots(file, ctx))
> -		goto out;
> +		return 0;
>  
>  	/*
>  	 * Resume after the last entry the previous call emitted. Only a seek
> @@ -875,21 +891,30 @@ static int proc_sys_readdir(struct file *file, struct dir_context *ctx)
>  	 * seeking to an arbitrary position always did.
>  	 */
>  	if (cursor && cursor->pos == ctx->pos) {
> -		entry_after(ctl_dir, cursor->name, cursor->len, &h, &entry);
> -		pos = ctx->pos;
> +		err = sysctl_dir_next(ctl_dir, &d, cursor->name, cursor->len);
>  	} else {
> -		first_entry(ctl_dir, &h, &entry);
> -		pos = 2;
> +		loff_t pos = 2;
> +
> +		err = sysctl_dir_next(ctl_dir, &d, NULL, 0);
> +		while (err > 0 && pos++ < ctx->pos)
> +			err = sysctl_dir_next(ctl_dir, &d, d.name, d.len);
>  	}
> +	if (err < 0)
> +		return err;
>  
> -	for (; h; next_entry(&h, &entry)) {
> -		if (!scan(h, entry, &pos, file, ctx)) {
> -			sysctl_head_finish(h);
> -			break;
> +	while (err > 0) {
> +		if (!d.skip) {
> +			err = proc_sys_fill_dirent(file, &d);
> +			if (err)
> +				break;
> +			if (!dir_emit(ctx, d.name, d.len, d.ino, d.type))
> +				break;
>  		}
> +		ctx->pos++;
> +		sysctl_cursor_set(file, d.name, d.len, ctx->pos);
> +		err = sysctl_dir_next(ctl_dir, &d, d.name, d.len);
>  	}
> -out:
> -	sysctl_head_finish(head);
> +	sysctl_dir_done(&d);
>  	return 0;
>  }
>  
> 
> -- 
> 2.53.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
