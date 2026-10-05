Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFA3E4C33D1
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 15:56:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791215810; cv=none; b=h/IMcOfhojBaNRe1Dek55piNELbDf+FRBiE8VZ0dKpINV4y2qCAjr14lhSPFHTSFHcjDM5ctJC0aLtb9hHvHsaNiVqYUG/fpX5ZrQ4xKcOVNVVOFBBNMz8bCeeoSm5wBYSLIeC9cS+lUCVioXzsRmYsyeAV57J1BLlyexZJ9CvA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791215810; c=relaxed/simple;
	bh=ZpgYj2i2ktsuTsRJOzRPxyGOUzOFinQj1Mdn99VcTJQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=BHu/tpaoOXXy+XOmh0EldJ3gVkPeuvrbiPOZdl6UIPOMT10r0D2dqdt+5a9+vx5WX8xcIWwnyod63HWb5UoRjj6wGJQTzq2iL5wPx8FFl5MbK7wkF/CloMtOzS8dxVBydbN3yyhvA87UsTzM4HX2g+drV3yt+RqAWyg2LijElsM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xc2iT1hc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xc2iT1hc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1D0111F0089D;
	Mon,  5 Oct 2026 15:56:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791215808;
	bh=5MssBip9aPRzeRSorwPEXOZcO1/x7++nhdL/tsro3pI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Xc2iT1hcfGxjFukVyXrue5VO/XeQlCBj3ncqd76UM1wEyOJ5B2bhUB+uqOea+26hV
	 Wt/kSK+TFmcUj0ajZ3CW83/ctpsE7DLbh3XmvGmxyzx7c+R8mgCtrqMF1Emp8Rjar7
	 eE9UEKxPbnBHwpVtbHqhpWcErQAOBY3Joht435RXuTTCm5dWuU9W+rW/p3ts0QFsPZ
	 yX61rzyUZk3AdCs6WCdoQNx9LwitsKgUKa79ryX3f8ZrAj4GS+NfkDKjUqRjiC1apo
	 b+V8wzztcz0tgyocrAGaLs0vdey2XhHUfuuTw5Kn24ipu8s5wkcJQvjwL5VFdpmrfp
	 eF/uZBnxhpYWA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 22B5EF40066;
	Mon,  5 Oct 2026 11:56:47 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 05 Oct 2026 11:56:47 -0400
X-ME-Sender: <xms:v8jDagcsru6Ig9zzUEWYGVCNzc3O7snJQxr9IwYpr4FYGFEuU-BMEA>
    <xme:v8jDatDcuZ8q9I28uWiG4NKgFV9xs58KvxxsflUsQX3eiTHPpemt9JqlWCAHekAwJ
    giAOs9OBA5EoBfk0lw2ENEvzwv85apTZZ4XBCNNpfgPewxUhvrziv6H>
X-ME-Proxy-Cause: dmFkZTGbsArUXG14+S49tcmuVu5/hDYmF0sLFJSYRcndtRDmUvqqtnq5334UwKOyoBAkMa
    /Cc/aS/QmxOMiQheMEk2Q+FnOYo5+zSo8C6tzOTLtlpEfH5aC2zF3N31PQMIXcPgi0vT5X
    ucnkZAGI6407soT5OCLnzKNRJDfwmm3onE1iMrJBBscaeqSxtTR0cy7pJAkBDR9y1+hhMF
    kimtOGSEAKXdC/djFq7kM6t4knhqHa37y4Uok/EKuoprQh1NCCX8LERvhxY6HkBCchFqyb
    74swN2onlHfcth6hb2mHDCCLnxE+73WwkgPQmFqDpJRX07zboKi8bURB4Lo1NjZPfgo6PD
    ZaAmFyPWLy4maxskUmKNVburKP0AEXtcZ6epLJCu1iiG/byAFM3OIqkiYTxTYwpFXOz829
    QZ+788waBIvcwslJ0/cN8wfZK/OE1WrCMos7ojeET7lNsFp5ahKXAE7dYr0+VaE+Z1z/QZ
    pbturqnwRr3q2m4RdPr2vhv9xTnaSIrhN06v5jwRVSi2Zb8ph2u4j0VsEMdNVNoXuw6fZt
    /K6RrIbwxian7C8uqkJ2gYU/BcTWO8fjGoN9u0rER0XOfx9cg0APSHLAHc5mB9M+Ln8MGg
    xHQKckFIDT5II87uX5wOJfg1By5E1xQA7qSKAZdBgqGjzjs/AVvQhJ7gu64w
X-ME-Proxy: <xmx:v8jDar8ulQNtGINpuZjOEmyOWyY4VcwgaQ96DrQu2Gq2CKFZ2LlPwQ>
    <xmx:v8jDaqyCDXmn1qQRJ05ddCPceto-KdNyvohqrVQelY_yiUZqOBp0LA>
    <xmx:v8jDajoD1ailysn9ca8F8TCzgs9OD45LNYcIT0b0TxqUb9b-2fqUmQ>
    <xmx:v8jDajrzEmJnNrYvTF2QWOAnKI7h4Y2XBM6IGQ7gew-o9b_in5EotQ>
    <xmx:v8jDarAU0OFsDDm40k3NTJCpBGtuO7rD0BpbR-wLVv6fAzF1T-FI2HvY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id EE000780075; Mon,  5 Oct 2026 11:56:46 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AZljx92lntAk
Date: Mon, 05 Oct 2026 11:56:26 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jinpyo Lee" <bint4b13@gmail.com>
Cc: linux-nfs@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 bobtobabz@gmail.com
Message-Id: <031205cd-1099-47a0-889f-ae203fd6c8c5@slotpi15m67>
In-Reply-To: <20260930055053.134716-1-bint4b13@gmail.com>
References: <20260930055053.134716-1-bint4b13@gmail.com>
Subject: Re: [PATCH v2] nfs/localio: pin clients during global invalidation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, Sep 30, 2026 at 02:50:53PM +0900, Jinpyo Lee wrote:
> Process one UUID at a time under the namespace list lock. Acquire a
> cl_count reference before releasing the lock, disable LOCALIO, and then
> drop the reference with nfs_put_client(). If the reference cannot be
> acquired, yield and retry so final teardown can remove the dying client
> from the list.

The reported use-after-free is confirmed.

> A full x86_64 kernel and modules build with GCC 13.3 and
> CONFIG_WERROR=y completed without warnings.

How was NFS_FS set for that build?

> +		spin_unlock(nn_local_clients_lock);
> +
>  		nfs_localio_disable_client(clp);
> +		nfs_put_client(clp);

nfs_put_client() is exported from nfs.ko. This call makes
nfs_localio depend on nfs.ko, and nfs.ko already depends on
nfs_localio for nfs_uuid_init(), nfs_uuid_begin(), nfs_uuid_end(),
and nfs_open_local_fh().

With NFS_FS=m and NFSD=m, NFS_COMMON_LOCALIO_SUPPORT is also "m", so
the two modules now require each other and neither can be loaded
first. With NFS_FS=m and NFSD=y, nfs_localio is built in and
references a symbol that lives in a module, so vmlinux cannot link.
Only NFS_FS=y avoids both.

nfs_common cannot call into nfs.ko. The pin has to be something
nfs_common owns, or the put has to go through a callback that the
NFS client provides.

Another issue: If client teardown drops its reference while this
loop holds the temporary one, the put above is the final one, and
nfs_free_client() or nfs4_free_client() then runs in the caller's
context. The callers here are the export flush path, NFSD file
cache shutdown, and nfsd_net_pre_exit(). For NFSv4 that means
nfs4_shutdown_client() and the callback teardown run while NFSD
is flushing or shutting down.

A pin that does not hold cl_count would avoid this as well as the
module dependency.


> +	for (;;) {
> +		spin_lock(nn_local_clients_lock);
> +		nfs_uuid = list_first_entry_or_null(nn_local_clients,
> +						    nfs_uuid_t, list);

This assumes nfs_localio_disable_client() always removes the head
entry from the list. It does not when another thread is already in
nfs_uuid_put() for that client.

nfs_uuid_put() clears ->net first, then drops nfs_uuid->lock around
each nfs_to_nfsd_file_put_local() call, and unlinks the uuid from
nn->local_clients only after the last file is closed. While that
thread is closing files, this loop finds the same uuid at the head
of the list, takes a reference, gets "false" back from
nfs_uuid_put() because ->net is already NULL, drops the reference,
and goes around again. That path has no cond_resched(), so it spins
until the other thread finishes. The other thread can sleep in
nfs_to_nfsd_file_put_local() or in wait_var_event_spinlock().

The splice in the old code moved such an entry off the list, so
the walk visited it once and went on. The new loop needs a way to
get past an entry that someone else is already disabling.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
