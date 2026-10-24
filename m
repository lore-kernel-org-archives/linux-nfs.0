Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792838324;
	b=HoQNukWmKRfE2AWsBxnpBGfapO86jVVI1+NljyIz/h9Eg2YQfA2UYw7GBiDo5Yc4ENBt
	 KZIwmpm7ila1TtFicWRnuqcBkj1okRJrRSzHfpysk0//80HJvVdXiu7fqv/ghFE3vMo+y
	 Vels0CQVW+lXYYK53F3EZ1K/QIIJUogqqDhPS0Z7FjpYJzwwsto/K/oBRTTCgtb3ymUPt
	 i9AYAcONzb9B9pbcol/ARJowQWIovGp96Iipxyfd5Goub4PnMUbZXt0LRaTvd3VypRDWr
	 sbIJ+CGkUrks8QINtApPTmZE7ZSfohj8EhGunDpyxzWK5kLVvgkXU7U9IL4Fr/9QYBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792838324;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ov5AiThtgjN27LwC+mIjyYFYu6KfFe86cDXxpqcFlaw=;
	b=aZF2zOWVU2jWOUznN30/SAdFNKvqJ0EAJukqX86joIs6CLILy3IJ6DYEXxDV+CeetCgP
	 O12IJfMJLYFx3AVAUnbLMa8Bm/s1g6nDvbcOSvWUHwQbUsiud1yhclTJvIhz5g/kAmo0R
	 ZBaSBBmAa8e+o95Rr6YBaye1S4ae4HFaaA/vshI9Gc78XVwJKbjOIuBI+i7oeHRVEuqXc
	 1zi9Zfo1xz3hVRN1z6owAdTIZDruph2a8yrzjoTffBO/x7uzP4YMn+DoXc8uZc0Xdy1iF
	 pThd2suc2ac9Q1NVE5qvsPtWHnoMrC9hV+tB7CDveVnHNxqm4ffnyCJFzqD+66mTqJQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=heSTl5AS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D41BA606A321;
	Sat, 24 Oct 2026 10:38:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=heSTl5AS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 84ACF1F01825;
	Sat, 24 Oct 2026 10:38:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792838323;
	bh=ov5AiThtgjN27LwC+mIjyYFYu6KfFe86cDXxpqcFlaw=;
	h=From:Subject:Date:To:Cc;
	b=heSTl5ASwoi8LETsrPpQAeiq4r6rhHoImnivo5u9ogY5wyfmiVkfENblfl+rE7rQc
	 x8RmrtglpdD+en/bbeNDwM7n4FCPd5ok0AbAaNeqYa+/98KSOX6ECQd4PJO2NmdoZF
	 p/VX4/5rTeeIpqQiLaiGdbXii0R030QpG5t3hBwXF5GXoAIRT9rDTAM6vVg9MrjJ28
	 Yqld0YvLyIoB2SMvs4G//QEoZPU3MMSkhktmNGOwYM2dCxmo1jhMbXQmGmA95QNguN
	 aXWZAw+F/T+eqALjfvOxUjy2DSYbnowpk5s6/O+wtywcRkg/53VF/2yfigp+29l9TM
	 H+yWOzNo8ZwQg==
From: Christian Brauner <brauner@kernel.org>
Subject: [PATCH 0/7] proc: block mounts below /proc/<pid>/net and on the
 links into /proc/self
Date: Sat, 24 Oct 2026 12:38:26 +0200
Message-Id: <20261024-work-procfs-fixes-v1-0-46b03c3a8fac@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMSw6DMAxEr4K8riUSRRT1KlUXSTDFrZogm34kx
 N1J6PLNzJsVlIRJ4dKsIPRh5ZwKmFMDcfLpTshDYbCt7UxrHX6zPHGWHEfFkX+k2AdrfDeYs3M
 9FG8WOoqiXW9/1nd4UFzqUV0Er4RBfIpTjV5eFxLYth0lSdwsjgAAAA==
X-Change-ID: 20261024-work-procfs-fixes-8b21a6d17448
To: linux-fsdevel@vger.kernel.org
Cc: linux-afs@lists.infradead.org, linux-nfs@vger.kernel.org, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
 Aleksa Sarai <cyphar@cyphar.com>, Chris Mason <mason@kernel.org>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=7474; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Dr3PNZ8G+Hu7egBMCK6LPlUx7/kcTHfAcZL5dUGWHbM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWTd6Vr3yO7xjwzZXbuu762WeuKzZcuZe2HP74udCTbd3
 Wj+JudfbUcpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEphgyMtz6ovLL+N7Zl69j
 zNteq12awH30W7VMfNmfn3e1zYxv22xh+F/xV9zDgc+56vdz/ls/2MsmLkw/WZY6u1Wbse+kVNM
 +WXYA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

In Linux 6.12 I stopped allowing mounts on the entries below
/proc/<pid>/fd/, /proc/<pid>/fdinfo/ and /proc/<pid>/map_files/ (cf.
[1]). This extends that to two more groups of entries:

(1) Everything below /proc/<pid>/net/.

    proc_net_d_revalidate() fails on every lookup since 1fde6f21d90f
    ("proc: fix /proc/net/* after setns(2)"). lookup_fast() answers that
    with d_invalidate() which detaches every mount on the dentry. That
    affects every mount namespace and includes locked mounts.

    So a mask on /proc/<pid>/net/dev goes away the first time anybody
    looks the name up. The directory is 0555 so anybody really means
    anybody. This is reproducible with a container that masks
    /proc/<pid>/net/dev with a locked bind mount and a stat() by nobody
    in the initial namespaces makes the real file show up again. So it's
    pointless.

    A mount that can't stick is better refused than taken away. I also
    have a version that makes proc_net_d_revalidate() check the network
    namespace instead so mounts there stick. But I think that's
    bullsh*t. It would make mounts on the net entries of other processes
    stick as well and the few users that try to mount there fail today
    anyway (see below).

(2) The links into /proc/self: /proc/self, /proc/thread-self,
    /proc/mounts, /proc/net and the afs and nfs links below /proc/fs/.

    These resolve to a different directory for every process. A mount
    on the link itself is crossed by every lookup through it in that
    mount namespace, so it redirects all processes at once. Mounting
    through the links keeps working and lands on the caller's own entry
    as before.

What I really wanted was to block mounting on anything below
/proc/<pid>/. That was the big hammer I mentioned in [1] years ago. We
can't... I did a pretty exhaustive survey of who mounts on the entries
below /proc/<pid>/ or on the links into it:

- GitHub code search and regex searches on Sourcegraph
- Debian Code Search over unstable
- the systemd units of every binary package in Debian 11, 12, 13 and
  sid, Ubuntu 22.04, 24.04 and 26.04, Fedora 43 and 44, CentOS Stream
  10, openSUSE Leap 16 and Tumbleweed and Arch
- clones of 46 container runtimes and orchestrators, the sandboxes
  (systemd, bubblewrap, flatpak, firejail, snapd, nsjail, minijail,
  Chromium and Firefox), Android and the rooting tools on top of it,
  and the AppArmor and SELinux policies
- detection rules, issue trackers, lore, LWN and the Q&A sites

The legitimate users all mount on entries of the process that does the
mount:

(1) systemd units that list /proc/self/... in ReadOnlyPaths=,
    ReadWritePaths= or ReadWriteDirectories=. systemd resolves
    /proc/self in the child of the service and binds the entry onto
    itself before it execs the service. If the mount fails the unit
    fails with 226/NAMESPACE and the "-" prefix doesn't help. That's
    netdata in Debian 11 and 12 and Ubuntu 22.04 and 24.04, opendht in
    Debian 12 and sid, Ubuntu 24.04 and Arch, accountsservice 22.x in
    Debian 12 and Ubuntu 22.04, OpenSearch 3, wazuh-indexer, TrueNAS
    SCALE, OONI's backend and the JupyterHub systemdspawner example. Of
    the 731 unit files on GitHub that name a /proc path in one of these
    directives 53 name an entry of the service itself.

(2) systemd's make_filesystem() binds /dev/null over /proc/self/mounts
    before it execs mkfs.btrfs so that it doesn't refuse a device whose
    other partitions are mounted. systemd-repart, systemd-homed and
    systemd-makefs use that.

(3) mkosi binds a fake /proc/self/mountinfo for grub-bios-setup.

(4) runc applies maskedPaths such as /proc/1/environ from the
    container's init when a config asks for it, bwrap does the same
    from its pid 1, firejail hides the name of its pid 1 and clampdown
    masks /proc/1/mem.

(5) Shell scripts that mount on /proc/$$/... and then exec, e.g.,
    luci-app-shadowrt on OpenWrt.

(6) Tests in systemd, elogind, LXC, libpathrs and bun.

Fedora's SELinux policy even grants fsadm_t and init_t the permission to
mount over their own entries because of (1) and (2). Sad, very sad...

Everything else I found is malware or offensive tooling:

Hiding a process by mounting over /proc/<pid> is catalogued as MITRE
ATT&CK T1564.013 and used in the wild by TeamTNT, Commando Cat, the KONO
DIO DA miner, KV-botnet, UNC2891 and kbotne. hackshell and emp3r0r ship
it and Elastic's endpoint rule kills any process that does it.

So blocking all of /proc/<pid>/ would break units in released
distributions and systemd itself. A rule that only lets a process
mount on its own entries, and on a directory only a bind of itself,
keeps (1) to (4) working, except for a few bwrap sandboxes that put a
tmpfs over directories like /proc/1/task, and stops all of the attacks.
I have that as well but it's not really a fix so we can delay it.

The remaining entries of a process only fail pid_revalidate() once the
task is gone and proc_flush_pid() invalidates them when it is reaped.
Their mounts go away together with the task and nothing gets revealed.

Nothing I found mounts on the links themselves and crun even has a
test that expects it to fail. The handful of units that mask entries
below /proc/<pid>/net/, e.g., Algo VPN's ReadOnlyPaths=/proc/net/pfkey
for strongswan, already fail today.

systemd's own lookup invalidates the dentry before it can bind onto it.
With this series they fail the same way. Apart from tests in libpathrs
and securejoin that had to be adapted the only fallout from the 6.12
change we found is one small project that handed libmount's new mount
api a /proc/self/fd/N target that move_mount() doesn't follow without
MOVE_MOUNT_T_SYMLINKS. Ubuntu even backported the 6.12 change to their
22.04 and 24.04 kernels this year.

Nuke this crap.

[1]: https://lore.kernel.org/r/20240806-work-procfs-v1-0-fb04e1d09f0c@kernel.org

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
Christian Brauner (7):
      proc: don't let an entry below /proc/<pid>/net be a mountpoint
      proc: don't let /proc/self and /proc/thread-self be mountpoints
      proc: don't let /proc/mounts and /proc/net be mountpoints
      afs: create /proc/fs/afs with proc_self_symlink()
      nfs: create the /proc/fs/nfsfs links with proc_self_symlink()
      proc: explain which entries can't be mountpoints
      selftests/proc: test which entries can't be mountpoints

 fs/afs/main.c                                   |   2 +-
 fs/nfs/client.c                                 |   4 +-
 fs/proc/generic.c                               |  31 ++++-
 fs/proc/internal.h                              |  18 ++-
 fs/proc/proc_net.c                              |   2 +-
 fs/proc/root.c                                  |   2 +-
 fs/proc/self.c                                  |   2 +
 fs/proc/thread_self.c                           |   2 +
 include/linux/proc_fs.h                         |   5 +
 tools/testing/selftests/proc/.gitignore         |   1 +
 tools/testing/selftests/proc/Makefile           |   1 +
 tools/testing/selftests/proc/proc-unmountable.c | 150 ++++++++++++++++++++++++
 12 files changed, 208 insertions(+), 12 deletions(-)
---
base-commit: 7be4bc52fd9e0e55dc9a2e0232b89427d2c4b614
change-id: 20261024-work-procfs-fixes-8b21a6d17448

