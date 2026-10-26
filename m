Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.130
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793019667;
	b=dr2zQGDJjIO9DKXBswhF8SjzcIi9X8HT3aC8VzN/Fheho5BOSg4PnaU8mptGJjhJ/mYi
	 otSfMPYvwhfKFRmUwqBlLO9O4RZWNGKm010NJG60Zam3xSYywFrrtacChZgaGVZzAqhOk
	 53C7sJlkiWTR50rnZX5cbtnn9DGGC9da/Igr49arByIOg1E2OkKdkYgmKk9B1jd2ItHmX
	 w6l23y82E0N72BBaJxSDxu0q3xJmq8ipEzzgYCXb/VUdv6vXwr7z4HzIpCsAZR3Eu7GnX
	 00auRrWGVqMUREkZy1RToL7uy9SyqpPdlGrOdn1AEBDnivhAtHzdXHe3Aj1Ph/nbLuA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793019667;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Rspamd-Queue-Id:X-Spam-Level:X-Rspamd-Server:
	 X-Rspamd-Action:X-Spam-Flag:X-Spamd-Result:X-Spam-Score;
	bh=ZVvR8/vPkVFRStnVaizcQOKEZOW0iOsbBk9wkmC0Mj8=;
	b=kBwYwBKT1wtvTUbRpnf+MkA3OHy0sCCpFmI8EII+MKvbAL65lY6tsQADT/wlndHuhM23
	 FxZDVPph5LPKfWDeYRm+2Ol8DsVFL9zdS2EvECjLzYR1lxbFtYhjMGNtrlyeyX74RJUOl
	 SxQ9NLdPR777GJWdI+29I4oqlUijYwHQqcD1l5U4yAg9rENADtgxqbjHlB0Pw1WpyZt6x
	 +SdCppJo8giaVHhiP8XE0+ytUxxXun62ymrUxx7cOJWdnfPGpeuvoXLv2oEXnQTsoDXMm
	 dXvaTW12WWi7bDiJPccEOPK5UAtQ/jcsDJHf0dItNZcZRoRdtiIN+RxOuV0zn62dhnA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yxS9FDwj;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=FwPZWA1d;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ADBqsyFF;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=B5ghY57L;
	arc=none smtp.remote-ip=195.135.223.130
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 91B55606A31B;
	Mon, 26 Oct 2026 13:01:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 91B55606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=yxS9FDwj;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=FwPZWA1d;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=ADBqsyFF;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=B5ghY57L
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id ED958222CD;
	Mon, 26 Oct 2026 13:01:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793019664; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZVvR8/vPkVFRStnVaizcQOKEZOW0iOsbBk9wkmC0Mj8=;
	b=yxS9FDwjEthDr6gpT+8E0Hhv7czGi1FcGngK3+U+31zorp8Y88ojShwmdyhmapORqcywoG
	20jlAyA3NoEP2XiCJGaLrp8vlhmpfeFH3KRKKPSsmqrnoIpn9wMQiTfoo8WtD6NAkUKdR2
	ep1qzDVwQNDQwk7IdM/Fn7R6R/ybH9A=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793019664;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZVvR8/vPkVFRStnVaizcQOKEZOW0iOsbBk9wkmC0Mj8=;
	b=FwPZWA1d7393CQtx2xk6xIa5ARejrxq59hWGvkcRCn8b6JmfdhSuR7MySCcquFOCw28oKK
	MwNsEEd7YFw2QdDA==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=ADBqsyFF;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=B5ghY57L
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1793019662; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZVvR8/vPkVFRStnVaizcQOKEZOW0iOsbBk9wkmC0Mj8=;
	b=ADBqsyFFDf8/RduuUBqT2VLneVtUVz45qxGEnzDNSJ6DjaY7rCcZDHMdDlobVXJtbULzqw
	02RO7LAzZKzTMbyF/s8sQw/EDiv/zZTUDpCGt4UwqB5KNp7yJHsqLBKAxgAC9bAmIrvD6d
	1d87355WGuJTyS6StCNJz8exV68gcNk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1793019662;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=ZVvR8/vPkVFRStnVaizcQOKEZOW0iOsbBk9wkmC0Mj8=;
	b=B5ghY57LbYWjz+dF40Qrg1Cw6IDGF5Qn7AwfVuNKMTR3YWuu+ovY7mzqPnIylrcGmW77gq
	GIIlvVJ606g1QKCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id BEFF013408;
	Mon, 26 Oct 2026 13:01:02 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id ruRAJg5P32pjWQAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 26 Oct 2026 13:01:02 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 4D3CCA1419; Mon, 26 Oct 2026 14:00:58 +0100 (CET)
Date: Mon, 26 Oct 2026 14:00:58 +0100
From: Jan Kara <jack@suse.cz>
To: Christian Brauner <brauner@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org, 
	linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Jan Kara <jack@suse.cz>, Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
	stable@vger.kernel.org
Subject: Re: [PATCH 0/7] proc: block mounts below /proc/<pid>/net and on the
 links into /proc/self
Message-ID: <zdwikcjfr2h3a5lifdjuw7dwrrqcptjxsyuqh4pd7hihhmwke4@k7pegq4xwfxi>
References: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
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
In-Reply-To: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
X-Rspamd-Queue-Id: ED958222CD
X-Spam-Level: 
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action
X-Spam-Flag: NO
X-Spamd-Result: default: False [-13.01 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	URIBL_BLOCKED(0.00)[suse.cz:dkim,suse.cz:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.com:email];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_COUNT_THREE(0.00)[3];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCVD_TLS_LAST(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	RCPT_COUNT_SEVEN(0.00)[9];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DKIM_TRACE(0.00)[suse.cz:+];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.cz:dkim,suse.cz:email,suse.com:email]
X-Spam-Score: -13.01

On Sat 24-10-26 12:38:26, Christian Brauner wrote:
> In Linux 6.12 I stopped allowing mounts on the entries below
> /proc/<pid>/fd/, /proc/<pid>/fdinfo/ and /proc/<pid>/map_files/ (cf.
> [1]). This extends that to two more groups of entries:
> 
> (1) Everything below /proc/<pid>/net/.
> 
>     proc_net_d_revalidate() fails on every lookup since 1fde6f21d90f
>     ("proc: fix /proc/net/* after setns(2)"). lookup_fast() answers that
>     with d_invalidate() which detaches every mount on the dentry. That
>     affects every mount namespace and includes locked mounts.
> 
>     So a mask on /proc/<pid>/net/dev goes away the first time anybody
>     looks the name up. The directory is 0555 so anybody really means
>     anybody. This is reproducible with a container that masks
>     /proc/<pid>/net/dev with a locked bind mount and a stat() by nobody
>     in the initial namespaces makes the real file show up again. So it's
>     pointless.
> 
>     A mount that can't stick is better refused than taken away. I also
>     have a version that makes proc_net_d_revalidate() check the network
>     namespace instead so mounts there stick. But I think that's
>     bullsh*t. It would make mounts on the net entries of other processes
>     stick as well and the few users that try to mount there fail today
>     anyway (see below).
> 
> (2) The links into /proc/self: /proc/self, /proc/thread-self,
>     /proc/mounts, /proc/net and the afs and nfs links below /proc/fs/.
> 
>     These resolve to a different directory for every process. A mount
>     on the link itself is crossed by every lookup through it in that
>     mount namespace, so it redirects all processes at once. Mounting
>     through the links keeps working and lands on the caller's own entry
>     as before.
> 
> What I really wanted was to block mounting on anything below
> /proc/<pid>/. That was the big hammer I mentioned in [1] years ago. We
> can't... I did a pretty exhaustive survey of who mounts on the entries
> below /proc/<pid>/ or on the links into it:
> 
> - GitHub code search and regex searches on Sourcegraph
> - Debian Code Search over unstable
> - the systemd units of every binary package in Debian 11, 12, 13 and
>   sid, Ubuntu 22.04, 24.04 and 26.04, Fedora 43 and 44, CentOS Stream
>   10, openSUSE Leap 16 and Tumbleweed and Arch
> - clones of 46 container runtimes and orchestrators, the sandboxes
>   (systemd, bubblewrap, flatpak, firejail, snapd, nsjail, minijail,
>   Chromium and Firefox), Android and the rooting tools on top of it,
>   and the AppArmor and SELinux policies
> - detection rules, issue trackers, lore, LWN and the Q&A sites
> 
> The legitimate users all mount on entries of the process that does the
> mount:
> 
> (1) systemd units that list /proc/self/... in ReadOnlyPaths=,
>     ReadWritePaths= or ReadWriteDirectories=. systemd resolves
>     /proc/self in the child of the service and binds the entry onto
>     itself before it execs the service. If the mount fails the unit
>     fails with 226/NAMESPACE and the "-" prefix doesn't help. That's
>     netdata in Debian 11 and 12 and Ubuntu 22.04 and 24.04, opendht in
>     Debian 12 and sid, Ubuntu 24.04 and Arch, accountsservice 22.x in
>     Debian 12 and Ubuntu 22.04, OpenSearch 3, wazuh-indexer, TrueNAS
>     SCALE, OONI's backend and the JupyterHub systemdspawner example. Of
>     the 731 unit files on GitHub that name a /proc path in one of these
>     directives 53 name an entry of the service itself.
> 
> (2) systemd's make_filesystem() binds /dev/null over /proc/self/mounts
>     before it execs mkfs.btrfs so that it doesn't refuse a device whose
>     other partitions are mounted. systemd-repart, systemd-homed and
>     systemd-makefs use that.
> 
> (3) mkosi binds a fake /proc/self/mountinfo for grub-bios-setup.
> 
> (4) runc applies maskedPaths such as /proc/1/environ from the
>     container's init when a config asks for it, bwrap does the same
>     from its pid 1, firejail hides the name of its pid 1 and clampdown
>     masks /proc/1/mem.
> 
> (5) Shell scripts that mount on /proc/$$/... and then exec, e.g.,
>     luci-app-shadowrt on OpenWrt.
> 
> (6) Tests in systemd, elogind, LXC, libpathrs and bun.
> 
> Fedora's SELinux policy even grants fsadm_t and init_t the permission to
> mount over their own entries because of (1) and (2). Sad, very sad...
> 
> Everything else I found is malware or offensive tooling:
> 
> Hiding a process by mounting over /proc/<pid> is catalogued as MITRE
> ATT&CK T1564.013 and used in the wild by TeamTNT, Commando Cat, the KONO
> DIO DA miner, KV-botnet, UNC2891 and kbotne. hackshell and emp3r0r ship
> it and Elastic's endpoint rule kills any process that does it.
> 
> So blocking all of /proc/<pid>/ would break units in released
> distributions and systemd itself. A rule that only lets a process
> mount on its own entries, and on a directory only a bind of itself,
> keeps (1) to (4) working, except for a few bwrap sandboxes that put a
> tmpfs over directories like /proc/1/task, and stops all of the attacks.
> I have that as well but it's not really a fix so we can delay it.
> 
> The remaining entries of a process only fail pid_revalidate() once the
> task is gone and proc_flush_pid() invalidates them when it is reaped.
> Their mounts go away together with the task and nothing gets revealed.
> 
> Nothing I found mounts on the links themselves and crun even has a
> test that expects it to fail. The handful of units that mask entries
> below /proc/<pid>/net/, e.g., Algo VPN's ReadOnlyPaths=/proc/net/pfkey
> for strongswan, already fail today.
> 
> systemd's own lookup invalidates the dentry before it can bind onto it.
> With this series they fail the same way. Apart from tests in libpathrs
> and securejoin that had to be adapted the only fallout from the 6.12
> change we found is one small project that handed libmount's new mount
> api a /proc/self/fd/N target that move_mount() doesn't follow without
> MOVE_MOUNT_T_SYMLINKS. Ubuntu even backported the 6.12 change to their
> 22.04 and 24.04 kernels this year.
> 
> Nuke this crap.
> 
> [1]: https://lore.kernel.org/r/20240806-work-procfs-v1-0-fb04e1d09f0c@kernel.org
> 
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Makes sense to me although I don't dare to judge all possible consequences
(I don't have much practical experience with container runtimes that play
these games). Anyway, feel free to add:

Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> Christian Brauner (7):
>       proc: don't let an entry below /proc/<pid>/net be a mountpoint
>       proc: don't let /proc/self and /proc/thread-self be mountpoints
>       proc: don't let /proc/mounts and /proc/net be mountpoints
>       afs: create /proc/fs/afs with proc_self_symlink()
>       nfs: create the /proc/fs/nfsfs links with proc_self_symlink()
>       proc: explain which entries can't be mountpoints
>       selftests/proc: test which entries can't be mountpoints
> 
>  fs/afs/main.c                                   |   2 +-
>  fs/nfs/client.c                                 |   4 +-
>  fs/proc/generic.c                               |  31 ++++-
>  fs/proc/internal.h                              |  18 ++-
>  fs/proc/proc_net.c                              |   2 +-
>  fs/proc/root.c                                  |   2 +-
>  fs/proc/self.c                                  |   2 +
>  fs/proc/thread_self.c                           |   2 +
>  include/linux/proc_fs.h                         |   5 +
>  tools/testing/selftests/proc/.gitignore         |   1 +
>  tools/testing/selftests/proc/Makefile           |   1 +
>  tools/testing/selftests/proc/proc-unmountable.c | 150 ++++++++++++++++++++++++
>  12 files changed, 208 insertions(+), 12 deletions(-)
> ---
> base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
> change-id: 20261024-work-procfs-fixes-8b21a6d17448
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
