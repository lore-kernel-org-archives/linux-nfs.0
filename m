Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F2ACD4499B9;
	Fri, 31 Jul 2026 17:28:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785518912; cv=none; b=hEpAHW3nxHvsZjKZ8CmDEH9Ymbuvg6/1SvLTXPanP+A4wFoefYd2ISCjoD2/XbAHTYib0y187f7cMXQuECNfj/TotEMXoSLjbvJ9XpGUmB/EC2+X/IUY39E9d9MBohCvL4LeuAXoaFC9LU3uw1j4ytfNx8DWXowKDqe4lZdwjHM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785518912; c=relaxed/simple;
	bh=u7mUbIpp3JuWA8oE4dPYBJVHPxZW99vHlPYVi8btNNU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ccl9cnxAriUTjfP043iLbe67rgV9MJIqbdUAS8HbOtYr8aMzUp/SCvFlmDetyrW4xb6D1ZylBcFjnKr1/NDNPIjbUsMyYXq4zh/wLMXgRYrCkuoF0GghoEY7Ev2ZCHnGp1fUMbh5Ttp0CLZmfIZIflvqUUK9JgPwJu675hE7XHQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GQMueJyC; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GQMueJyC"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A60A1F00ACA;
	Fri, 31 Jul 2026 17:28:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785518910;
	bh=n0nY8eb6duFBCnIjpi6tgFL9WfFHD2oP+LQ8hrcz/p4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=GQMueJyC6ehPl5Kc2nQjCidlOfj3BNUzjKB2MWyK6texTpl3vghrXW/MPs/D4bGvh
	 4jHFvoK7bFOmQQsxyCUt1agNTavHQBiH9gWFvau0iIc0REYgOWiOe+vBNiu0/02E5q
	 cw6mkBnadi+AAqzGHoNLVWsBe5+0kBcmdBR1cXcjm3sIDPXyaYbCBhS9IosX3LoF0E
	 spyPL3PwkftqfVSU9esHYxNWNJm8s/k0SaEMn+qOQbEE7s31QrRLj5jsu4UAgFM63X
	 Eo1z/gScqLZZdKgKmBxESuMh9isR2ykdAqCVsAyLgJLPaFIIypqM4BcmFHPWY5rsyw
	 izfMRQ3Fae4Dg==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 14B1EF4007B;
	Fri, 31 Jul 2026 13:28:29 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Fri, 31 Jul 2026 13:28:29 -0400
X-ME-Sender: <xms:PdtsapeemnOLqlHxGvkdzSC5q_0W9TqbmFoSQ5MohOcq5RS3A7Tlsg>
    <xme:PdtsaiAEFCRIquEYAHHO6j6QkY_Sj0AkrmBoZvtZPbPGUSCMgjJ9-cqrNPlTxt6br
    925IGX7N2iWFm0HN99zVesJvDHVFwAWPX2Yv6GRxTS3Q2H7wluxidNs>
X-ME-Proxy-Cause: dmFkZTFsbWZ4BGfYF2AdxvvmY8ciSf3LqT3NIpi4PdzQRMc1RHZyDLJ4hwccCOQ/+SBsYg
    CXRdvjUfmEXy9XoPwbjIgbwYdBIr6yZLkWqifuBmKGzTzNaiIwsymO6dQAm1qhQjQZHKxo
    5WzLKe5g9LuZ7UwF3vWi9qOUtjc5ncEK1lt2AsQ4rOtmi+BFebM/D75F57Vk2k9W1M13Ba
    o82Lt3uBgM0Xkf7l7BjGAD6ahrivEHk81/leey/uj71Sd6G/DDjWeQFNIL1yCWkqfz6Cuy
    9VnmQaHpq1NS/iXnGI7pEtOHYQE31iEgUk0cMdUuoUNwS3HyyhIC/DxBamjGXKoFARkXqU
    1lnyrKPByUZ18AuyNV+C+Pv+F4OjB5QU/1uLsDmFfBEUsQjmOM/5UOuXMaf9BI9Z8R7TJe
    zIbJaDk51UZccjfPyM9eMWGHbwZGbpd9f81VPlOOHpkWXhywN8aGiJxWG63JHXupglZ4Ni
    jitVHls7nQweSYlDWU+zePUoMhfXzaadxJDg3UdadstjOzkNeO6AF7jjvRT1BUoVo3NHgi
    h2GsNs3bParsKSrH2IOLVVFFW9ud2S3hPNxHwYgxqwhITUrMUk5em6nXHMVJcGydTzKw6/
    b+iZUP1yinrdYJVjj0AM3RdDY8qkj+kFwkL1ZxTMby0qZzmetUAftPQtm+8g
X-ME-Proxy: <xmx:PdtsatkB5yE8cLLY8AzIvnZEBxFNcwttp9a9aRyrf75mNRPN4YJ8ww>
    <xmx:PdtsakoqQppXx5P3_93CN9o-qQS3PAAweAkLMg_QGpIrGQP9r-m9Ew>
    <xmx:PdtsavC2sxCEWWe9dMt0zTnPhnMVHbUCrMO0z8Yf91ozOD3tW4MXxg>
    <xmx:PdtsanHBzoqkOHT1bA_6zQ0XrkcKGy9MTV3IoHkiOefW7AsHS6OswA>
    <xmx:Pdtsap15inS78_NiOZJGFnYOsCJ6iZGJLUHn9NaqcV225gPeq2pSSGni>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E3EC8B60F89; Fri, 31 Jul 2026 13:28:28 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A7VXYS5OSsVV
Date: Fri, 31 Jul 2026 13:28:08 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Chuck Lever" <cel@kernel.org>, "Paul Moore" <paul@paul-moore.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: "Stephen Smalley" <stephen.smalley.work@gmail.com>,
 "Achilles Gaikwad" <achillesgaikwad@gmail.com>,
 "Casey Schaufler" <casey@schaufler-ca.com>,
 "Christian Brauner" <brauner@kernel.org>, linux-nfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Message-Id: <33ba1c27-27cf-4b83-9c69-1ec40023a5d2@app.fastmail.com>
In-Reply-To: <8df686c5-f1cd-4298-97de-14c2c4638496@app.fastmail.com>
References: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
 <20260725200958.4471-1-cel@kernel.org>
 <CAHC9VhSGn6UQ1__HtqjKWD1KgyMOhHYYKny5HnVuPAuvqZR9aw@mail.gmail.com>
 <CAHC9VhS6B1yW+8G9Biqit5CAmcg4CwCaWbq1B+Qpo2n6a=yqnw@mail.gmail.com>
 <8df686c5-f1cd-4298-97de-14c2c4638496@app.fastmail.com>
Subject: Re: [PATCH v2] security,fs,nfs,net: update security_inode_listsecurity()
 interface
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Fri, Jul 31, 2026, at 1:07 PM, Chuck Lever wrote:
> On Fri, Jul 31, 2026, at 12:09 PM, Paul Moore wrote:
>> On Sun, Jul 26, 2026 at 11:03=E2=80=AFAM Paul Moore <paul@paul-moore.=
com> wrote:
>>> On Sat, Jul 25, 2026 at 4:14=E2=80=AFPM Chuck Lever <cel@kernel.org>=
 wrote:
>>> >
>>> > On Mon, Apr 28, 2025 at 03:50:19PM -0400, Stephen Smalley wrote:
>>> > > Update the security_inode_listsecurity() interface to allow
>>> > > use of the xattr_list_one() helper and update the hook
>>> > > implementations.
>>> >
>>> > This commit wedges an NFSv4.2 client running fstests.
>>> >
>>> > A kdevops fstests run against nfsd-next hangs at generic/086.  The
>>> > client stops making progress and never recovers:
>>> >
>>> >   watchdog: BUG: soft lockup - CPU#3 stuck for 250s! [086:60396]
>>> >   Comm: 086 Tainted: G  D  L  7.2.0-rc4
>>> >     __pv_queued_spin_lock_slowpath
>>> >     _raw_spin_lock
>>> >     nfs4_xattr_set_listcache [nfsv4]
>>> >     nfs4_xattr_discard_cache [nfsv4]
>>> >     nfs4_xattr_cache_scan [nfsv4]
>>> >     do_shrink_slab
>>> >     drop_caches_sysctl_handler
>>> >
>>> > The D taint says something died earlier.  It did: by the time the
>>> > lockup fires, the client has already taken two dozen NULL pointer
>>> > dereferences, all of them in the same place:
>>> >
>>> >   BUG: kernel NULL pointer dereference, address: 0000000000000000
>>> >   RIP: _copy_from_pages+0x44/0xd0 [sunrpc]
>>> >     nfs4_xattr_cache_list [nfsv4]
>>> >     nfs4_listxattr [nfsv4]
>>> >     vfs_listxattr
>>> >     __x64_sys_listxattr
>>> >
>>> > The two stages are connected.  nfs4_listxattr() declares its
>>> > remaining-size accumulator as an unsigned size_t.  On a size query,
>>> > where listxattr(2) passes a NULL buffer and a length of zero,
>>> > xattr_list_one() decrements that accumulator for the SELinux label
>>> > without regard to the NULL buffer, so it wraps to a very large
>>> > value.  nfs4_xattr_cache_list() then sees a NULL buffer paired with
>>> > a buffer length large enough to pass its own bounds check, and
>>> > copies into it.  The fault happens while the xattr listcache
>>> > spinlock is held.  Task exit does not release spinlocks, so the
>>> > lock is orphaned, and the next shrinker pass spins on it until the
>>> > watchdog fires.
>>> >
>>> > The reproducer is a plain getfattr on a file on an NFSv4.2 mount
>>> > with SELinux enforcing, which is what fstests generic/086 arrives
>>> > at by way of a drop_caches write.  No fstests machinery is needed
>>> > to see the oops.
>>> >
>>> > An audit of the listxattr path pointed here, so I built nfsd-next
>>> > with this commit reverted and reran the full fstests nfs_v42
>>> > section on the same pair of guests.  745 tests, no soft lockup, no
>>> > oops, and generic/086 passes.  The two failures that remain,
>>> > generic/033 and generic/258, are unrelated to xattrs.
>>> >
>>> > I am not proposing the revert as the fix.  Achilles Gaikwad has
>>> > already posted a targeted patch for the accounting itself:
>>> >
>>> >   https://lore.kernel.org/linux-nfs/20260707152305.15324-1-achille=
sgaikwad@gmail.com/
>>> >
>>> > Whether the right answer is that patch, a change to
>>> > xattr_list_one() so it leaves the remaining size alone when the
>>> > buffer is NULL, or hardening nfs4_xattr_cache_list() against a NULL
>>> > buffer, is for the three of you to settle.  I am reporting the
>>> > severity, because the accounting bug is not confined to a short
>>> > size query: on a filesystem that caches xattrs behind a lock, it
>>> > takes the whole machine down.
>>> >
>>> > I can test whatever you settle on against the same setup.
>>>
>>> I reviewed Achilles's patch back in early July and it looked okay to
>>> me (see my tag in my email in that thread from July 7th).  I had
>>> figured that the NFS folks would have wanted to pull that via the NFS
>>> tree since it only touches NFS code.  If they would prefer I send it
>>> up to Linus via the LSM tree I can do that, but I would appreciate an
>>> ACK and Tested-by from someone on the NFS side.
>>>
>>> While I don't suspect it will be very interesting, I just started
>>> building a test kernel with Achilles's patch that I'll run through t=
he
>>> normal selinux-testsuite automated testing.
>>
>> Chuck, Anna, Trond, Jeff - can someone ACK Achilles's patch below or
>> suggest what changes might be necessary?  There is a known regression
>> (see the existing mails) and we need to fix this before v7.2 ships.
>> I'm happy to send this up to Linus if you would prefer, but I would
>> *really* like to see an ACK from someone on the NFS side.  If I don't
>> see any comments be early next week I'll send this up to Linus via the
>> LSM tree.
>>
>> https://lore.kernel.org/linux-nfs/20260707152305.15324-1-achillesgaik=
wad@gmail.com/
>
> Since Achilles' patch is client-side, I shouldn't Ack it.
>
> I don't see this patch in Anna's tree either. A response from the
> NFS maintainers would be helpful.

Looks like I did have it in a branch with other commits for testing, but=
 I
never pushed it out. I've moved it over to my public linux-next and will
pass it along to Linus in the next few days.

Anna

>
>
> --=20
> Chuck Lever
