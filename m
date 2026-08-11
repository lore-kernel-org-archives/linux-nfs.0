Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B1D836E48C;
	Tue, 11 Aug 2026 18:20:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786472417; cv=none; b=VOLgtC2EDiqIhRxNoMKxSUJTrB+O1P064Iw/UfyWQWzuR+tznRnea0vsTr4ialzlSZmeO8KGIv+MR9FGrHCStMo9in7EqAngrndoTdV+FDFkYp1IQ1YE6VYqkbNLFYfcwy8kO9T/yH2A7b0jLBsFLEBcvBYPuBZTGLJ6DB9K8OI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786472417; c=relaxed/simple;
	bh=Wiawra5kKkPi4nsu5a2lb9gjs/CukzGmHJKtuwRoeUA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lPPKgdZ1m9KhKeTOwn5siiPbi13dG7NfXkL61JB+9AKmw3yfMX7vSgkQTh6rO1h+cpvCdQJclrkCB565HwqkLUa/cbNCr7CJpN0qFOtAVbwS4gv7sVL3nyxLJA9efUCXth6EVE8qeVrQ+jo+MY/UzrjOu6Xaclimt8mpR03lInk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LUR7edvf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LUR7edvf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2BFD51F000E9;
	Tue, 11 Aug 2026 18:20:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786472416;
	bh=82HGZsPxUpcnk6FVJkVR/8JEXad9K6uAipsabFS3WKc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=LUR7edvfMpZPiPQqCKTxT7C3PKhPuFxcyN3AHk76XXbKOfB1CBf4sTCfdKV5Ptp4R
	 B0Rr4m/ibr0q7uguVB5xMvUrzpA8/e+L2+D9mySRGX5Sq0cqu+VYzXeRVwQrmn8234
	 LLnbTRtpZli/PRucZ123m1vW61I1Ec7S9rn6NHL66Uz8AgA+u1osyHEAldC8tMp/bB
	 3BQBwPF2oCqK3n/Lk1m+IdZa16AC9fzGUZA/cJejpmaPF4+nICKJrHugBAWx1OXFHB
	 1g92/VYVXhZEus1ZDlSComjJTk6nmL6YLxSHx6h3SPp+ggcFhbtYmnXS3XfL7840n/
	 mAUvBvG/OpnMw==
Date: Tue, 11 Aug 2026 18:20:12 +0000
From: Eric Biggers <ebiggers@kernel.org>
To: Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <linux@jaseg.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Baoquan He <baoquan.he@linux.dev>, Mike Rapoport <rppt@kernel.org>,
	Pasha Tatashin <pasha.tatashin@soleen.com>,
	Pratyush Yadav <pratyush@kernel.org>,
	Dave Young <ruirui.yang@linux.dev>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>, David Howells <dhowells@redhat.com>,
	Jarkko Sakkinen <jarkko@kernel.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Shuah Khan <skhan@linuxfoundation.org>,
	Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Lukas Wunner <lukas@wunner.de>, Ignat Korchagin <ignat@linux.win>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Keith Busch <kbusch@kernel.org>, Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Mimi Zohar <zohar@linux.ibm.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	Marc Dionne <marc.dionne@auristor.com>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>, "Theodore Y. Ts'o" <tytso@mit.edu>,
	Jaegeuk Kim <jaegeuk@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Alasdair Kergon <agk@redhat.com>, Mike Snitzer <snitzer@kernel.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	Benjamin Marzinski <bmarzins@redhat.com>, kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, keyrings@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org,
	linux-afs@lists.infradead.org, netdev@vger.kernel.org,
	linux-fscrypt@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dm-devel@lists.linux.dev
Subject: Re: [PATCH v2 00/13] CRASH_WIPE_SECRETS: Wipe secrets before kdump
 (was: CRASH_ZEROIZE)
Message-ID: <20260811182012.GB2895176@google.com>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>

On Tue, Aug 11, 2026 at 07:52:49PM +0200, Jan Sebastian Götte wrote:
> I'm using linux on an embedded target in a Hardware Security Module-like
> application. One requirement is that I want the system to be able to
> quickly erase its memory when it detects physical tampering. I'm
> approaching that by using kdump to load into a small payload that
> instead of dumping RAM, erases RAM from start to end. However, writing
> all of RAM, especially on an embedded target, is rather slow. For this
> reason, I propose the mechanism in this patch series:
> 
> Add CONFIG_CRASH_ZEROIZE (default off), which when enabled makes various
> subsystems handling secret data do a quick, targeted wipe of these
> secrets before kdump. This behavior might also be interesting in cases
> where you run a normal kdump kernel but you still want to keep things
> like fde crypto keys out of these dumps.
> 
> CONFIG_CRASH_ZEROIZE is a best effort, defense in depth solution. There
> are circumstances, such as when a panic is triggered after memory
> corruption, or when a panic interrupts some operation that mutates data
> structures under locks, when the kernel cannot safely wipe some memory
> areas. The handlers proposed in this series will just print a warning
> and skip the affected areas in this case.
> 
> This series introduces handlers for the major locations I found where
> having this sort of thing makes sense. Notable omissions right now are
> the Ceph and CIFS subsystems. I have WIP patches for these, but since I
> can't easily test them right now, I omitted them from this patch set for
> now. Currently included locations are:
> 
> * various key types in security/keys
> * rxrpc
> * fscrypt
> * dm-crypt
> * crypto tfm instances
> * secretmem (which I'm going to start using in my application)
> 
> I've verified this patch series on an ARM64 target using the helper code
> at https://codeberg.org/yasec/crash-wipe-test . This code stuffs the
> affected kernel subsystems with keys and secret data, then crashes the
> system, takes a RAM dump and verifies the dump is clean of secrets. Note
> that the helper code is partially LLM-generated, so read with care. It
> passes a positive control test with the config option disabled.
> 
> The patch series applies on top of linux-next but should work on 7.0.0,
> too. I've tested the patches on a Arduino uno Q (Qualcomm QRB2210,
> ARM64) embedded target.

Can we not?  It's already hard enough to zeroize keys and data at the
normal end of their lifetime in the kernel: that's something that is
always a struggle, with fix patches regularly going by for many years
and many subsystems never fixed at all.  If we can barely even do that,
we aren't going to be able to correctly and completely implement and
maintain separate zeroization code for every kernel subsystem that runs
only on kernel panics and has special constraints, like not being able
to take locks.

This is never going to be done either, with the scope always wanting to
grow to include other keys and data.  You may think this series covers
"almost everything" but it's actually not even close.

Could you perhaps narrow the scope to one or two things that actually
are useful and can reasonably be supported for the application?  For
example, secretmem seems to be the only thing you mentioned that you're
actually planning to use.

- Eric
