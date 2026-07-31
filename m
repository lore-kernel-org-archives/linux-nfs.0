Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F07B449B11;
	Fri, 31 Jul 2026 17:07:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785517680; cv=none; b=NhQazz3SlzOZXQSl3nJ3bpuAaDY+6TjMIlUgD241MKXeOpwqZ331V9vR9e5MYMx0aW7Y/z62bLKgGbtoRUjiMMi2eytW7qti8lZwsxs5iZN7xP4zWQnYBGVkmlQ7KrSTFZ/ckERrdDVuQrsM/90cSe28onVjOu5saeNP4AEdQeA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785517680; c=relaxed/simple;
	bh=S8fSGliVXVVir45f14wKNX7a8oqezVQ/Gxda8CGGb+g=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=E9InBPZICO3w2x1GpqD2m61hZHlxJhgx0sxt6Y11XdXrEY5tg2YiptenFepW4CL8DzGeTllcb9nr9tnIabCnauhdT8eoGHFr9siWcTDRgaM6Axxr73nK0wY/aiN7ZyIo6Fhl1ntQN+9njBEPct47qivdlQn6lmPuqizPXIUdWPQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B0a36GEv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B0a36GEv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 682571F00ACF;
	Fri, 31 Jul 2026 17:07:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785517678;
	bh=76n8ogS5bvh6Aa57NAwJg5S8lZ4dDrIJZvLJprm/my0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=B0a36GEvLbpn9QVan3laky6gn3aQVi1ciZdIQo4Dl7zYLIES2DCgmbWx5Pdw+5PqA
	 RTmK2ZfVEmgi0FN+5jCIAx8MDLL7w8x+UqNj1hWrNQC8cBOxFG5cjo/tWAQr8uusU7
	 Q+DepdEQzOkkPDUemceVbRwYWo8U1bixyrE/xOlGxb6pssTT3Hi1mSYFFlHdI2AGTZ
	 L9g9PsqZCIk3QQFZXHympTanBHbKWY4ZGBmro1OqB0OQh9rFBuf9/+xh1nl/pX82tP
	 1VYjpbXLaKX81tsMuQIGdwgy1l7U80D7i9VvTK/xpgkDyhK+Zzkoz3NZ/7ZOPLHgmA
	 ZfexqMxe2KmBw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D784F40081;
	Fri, 31 Jul 2026 13:07:57 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 31 Jul 2026 13:07:57 -0400
X-ME-Sender: <xms:bdZsauAIFW7vgjpZ2A-fyU99zZH-jRtKAdYphCSSEJhiw2lGGzQPoQ>
    <xme:bdZsajXb_A6vot4t_e48GEOndvWf1Dh5WEi8VfAlR8rIn5sEA_95j5NB4n1a_HhDV
    i8aM_H0eEe34yuxSCwtjLRzYvee8D5TXyBZ3O8ykRlGmTOz7iwlo_4>
X-ME-Proxy-Cause: dmFkZTFHoUK65Pa5sEOsC3lqPKqH2cP5ocLcMGuNPDYjcvwbrpjxIA6UBdBOCLlQh0j4H1
    Pj9gSMi9Gu8CW2l8dItkL7a1blLpRhHhl/SVr7fC4BZYYI5pp/ObpsHiDIUWplOdKLtswB
    8GGRPdXlxG5bDDzyuzVCMUXZeBO8ViVS0u42khjjz/YnUrs3WfCoRIJ6yi2KMxzVwrXKQj
    nzS5aBdA3CY6jxHNCdvhAksqH9isagevY/wvw4FZ8VMJyLvZl43V0bbNoN7ZZjG4nfwcmF
    8SAtSCH39yoSQIJy9awye0z8ozqs1MI9bW2Kkcz752X919vjHUwsKu5RLPJSB6SGLLLKIC
    n/gsAQGSVHStLQZX+iqgO6gyA36eXyPmxP05GsGvIHOkMe1DHQhTG8BKEmLgFUcZtVY5u8
    Inpqu83Qxo3K8sW4ROueMCv6gV00YKNEiwL2P2IodsHDOZUJT8DygVlwLS/4zp779IOpRd
    +iKFW1Tb1heSVVeqByYtjbWYODGP0iP4Q40vuhHdfDwHFUQ2zwYFRywAhTFH3Gy/YpUrBB
    tFH4JcXf09fHQdUfm29twHNp/vRR+VAdVaOD+yXhyoyQL+wps6sNWhA6XmSOX8IMeYm5yk
    OLZi7q/WSRfAmtDpKC5GKvf9DzqLIm1NJzALoObxwZTT5IyLgZUCEgaCR5fQ
X-ME-Proxy: <xmx:bdZsaupZJ0A0lZ6JUInjYKht0q7uonDcs0GqTC3950sgq2Jq3tF4FQ>
    <xmx:bdZsaofvcjixd7PFgzqkxwIpScbO19Qm8zvIpUMCgf6WRe0WcmKsWQ>
    <xmx:bdZsaul_6Pa45Sm9zYZ94v1IYQHAe3EuqwNv-SD9qusiZZ-7w-NYGg>
    <xmx:bdZsanYJZC9Lur66LtiN_3Nc-hrEG_53zkL6I51ExvYkQcquPTYTmw>
    <xmx:bdZsar6hamFu5h8yFoYxzYnz51rNRLQ-U-hqeLb3mTxiVECQmFg5WYNi>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4917C780070; Fri, 31 Jul 2026 13:07:57 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AcdnrL9JmIuZ
Date: Fri, 31 Jul 2026 13:07:37 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Paul Moore" <paul@paul-moore.com>, "Anna Schumaker" <anna@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Jeff Layton" <jlayton@kernel.org>
Cc: "Stephen Smalley" <stephen.smalley.work@gmail.com>,
 "Achilles Gaikwad" <achillesgaikwad@gmail.com>,
 "Casey Schaufler" <casey@schaufler-ca.com>,
 "Christian Brauner" <brauner@kernel.org>, linux-nfs@vger.kernel.org,
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Message-Id: <8df686c5-f1cd-4298-97de-14c2c4638496@app.fastmail.com>
In-Reply-To: 
 <CAHC9VhS6B1yW+8G9Biqit5CAmcg4CwCaWbq1B+Qpo2n6a=yqnw@mail.gmail.com>
References: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
 <20260725200958.4471-1-cel@kernel.org>
 <CAHC9VhSGn6UQ1__HtqjKWD1KgyMOhHYYKny5HnVuPAuvqZR9aw@mail.gmail.com>
 <CAHC9VhS6B1yW+8G9Biqit5CAmcg4CwCaWbq1B+Qpo2n6a=yqnw@mail.gmail.com>
Subject: Re: [PATCH v2] security,fs,nfs,net: update security_inode_listsecurity()
 interface
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Fri, Jul 31, 2026, at 12:09 PM, Paul Moore wrote:
> On Sun, Jul 26, 2026 at 11:03=E2=80=AFAM Paul Moore <paul@paul-moore.c=
om> wrote:
>> On Sat, Jul 25, 2026 at 4:14=E2=80=AFPM Chuck Lever <cel@kernel.org> =
wrote:
>> >
>> > On Mon, Apr 28, 2025 at 03:50:19PM -0400, Stephen Smalley wrote:
>> > > Update the security_inode_listsecurity() interface to allow
>> > > use of the xattr_list_one() helper and update the hook
>> > > implementations.
>> >
>> > This commit wedges an NFSv4.2 client running fstests.
>> >
>> > A kdevops fstests run against nfsd-next hangs at generic/086.  The
>> > client stops making progress and never recovers:
>> >
>> >   watchdog: BUG: soft lockup - CPU#3 stuck for 250s! [086:60396]
>> >   Comm: 086 Tainted: G  D  L  7.2.0-rc4
>> >     __pv_queued_spin_lock_slowpath
>> >     _raw_spin_lock
>> >     nfs4_xattr_set_listcache [nfsv4]
>> >     nfs4_xattr_discard_cache [nfsv4]
>> >     nfs4_xattr_cache_scan [nfsv4]
>> >     do_shrink_slab
>> >     drop_caches_sysctl_handler
>> >
>> > The D taint says something died earlier.  It did: by the time the
>> > lockup fires, the client has already taken two dozen NULL pointer
>> > dereferences, all of them in the same place:
>> >
>> >   BUG: kernel NULL pointer dereference, address: 0000000000000000
>> >   RIP: _copy_from_pages+0x44/0xd0 [sunrpc]
>> >     nfs4_xattr_cache_list [nfsv4]
>> >     nfs4_listxattr [nfsv4]
>> >     vfs_listxattr
>> >     __x64_sys_listxattr
>> >
>> > The two stages are connected.  nfs4_listxattr() declares its
>> > remaining-size accumulator as an unsigned size_t.  On a size query,
>> > where listxattr(2) passes a NULL buffer and a length of zero,
>> > xattr_list_one() decrements that accumulator for the SELinux label
>> > without regard to the NULL buffer, so it wraps to a very large
>> > value.  nfs4_xattr_cache_list() then sees a NULL buffer paired with
>> > a buffer length large enough to pass its own bounds check, and
>> > copies into it.  The fault happens while the xattr listcache
>> > spinlock is held.  Task exit does not release spinlocks, so the
>> > lock is orphaned, and the next shrinker pass spins on it until the
>> > watchdog fires.
>> >
>> > The reproducer is a plain getfattr on a file on an NFSv4.2 mount
>> > with SELinux enforcing, which is what fstests generic/086 arrives
>> > at by way of a drop_caches write.  No fstests machinery is needed
>> > to see the oops.
>> >
>> > An audit of the listxattr path pointed here, so I built nfsd-next
>> > with this commit reverted and reran the full fstests nfs_v42
>> > section on the same pair of guests.  745 tests, no soft lockup, no
>> > oops, and generic/086 passes.  The two failures that remain,
>> > generic/033 and generic/258, are unrelated to xattrs.
>> >
>> > I am not proposing the revert as the fix.  Achilles Gaikwad has
>> > already posted a targeted patch for the accounting itself:
>> >
>> >   https://lore.kernel.org/linux-nfs/20260707152305.15324-1-achilles=
gaikwad@gmail.com/
>> >
>> > Whether the right answer is that patch, a change to
>> > xattr_list_one() so it leaves the remaining size alone when the
>> > buffer is NULL, or hardening nfs4_xattr_cache_list() against a NULL
>> > buffer, is for the three of you to settle.  I am reporting the
>> > severity, because the accounting bug is not confined to a short
>> > size query: on a filesystem that caches xattrs behind a lock, it
>> > takes the whole machine down.
>> >
>> > I can test whatever you settle on against the same setup.
>>
>> I reviewed Achilles's patch back in early July and it looked okay to
>> me (see my tag in my email in that thread from July 7th).  I had
>> figured that the NFS folks would have wanted to pull that via the NFS
>> tree since it only touches NFS code.  If they would prefer I send it
>> up to Linus via the LSM tree I can do that, but I would appreciate an
>> ACK and Tested-by from someone on the NFS side.
>>
>> While I don't suspect it will be very interesting, I just started
>> building a test kernel with Achilles's patch that I'll run through the
>> normal selinux-testsuite automated testing.
>
> Chuck, Anna, Trond, Jeff - can someone ACK Achilles's patch below or
> suggest what changes might be necessary?  There is a known regression
> (see the existing mails) and we need to fix this before v7.2 ships.
> I'm happy to send this up to Linus if you would prefer, but I would
> *really* like to see an ACK from someone on the NFS side.  If I don't
> see any comments be early next week I'll send this up to Linus via the
> LSM tree.
>
> https://lore.kernel.org/linux-nfs/20260707152305.15324-1-achillesgaikw=
ad@gmail.com/

Since Achilles' patch is client-side, I shouldn't Ack it.

I don't see this patch in Anna's tree either. A response from the
NFS maintainers would be helpful.


--=20
Chuck Lever
