Received: from mta1.migadu.com (out-197.mta1.migadu.com [95.215.58.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B17EA3BFE2F
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 08:25:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786955136; cv=none; b=kobqwkcASO8uy1ROT+A3vlg/RdPzRbilKql6XAuPNd8sNLJJEJwLu7+H4SB3/RvE99eOUOkxIZxQySxiSJQsnzFD883REBz2e3BtT2uXfJYEEbEfLrK0n8J1sXSp+9g0MptXajr/1psKcPENDVI81gGKIjrs6yxw6uYwp3GyKjI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786955136; c=relaxed/simple;
	bh=eYNadUi07A8AhvVYvTwlB5KEurgeLlJSPKo7wDdWLLE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=lhGSn3qvFGHQUoQH1UMnvBZIW/G7JjuqqCNH72s8305PGkM2ZaXrddysH0jFuvALizLKqKuPSFCQEDwwfAhKefAxklWIrOwJqR3uAZMs8hNti913/POrAeYqI4mFePHCUZy+OCIsNsDRFT1ax/+WPfxPssx6sfp+0BkTC/c5c/k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=LOyqKIP8; arc=none smtp.client-ip=95.215.58.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="LOyqKIP8"
X-Envelope-To: linux-nfs@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=eYNadUi07A8AhvVYvTwlB5KEurgeLlJSPKo7wDdWLLE=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1786955128; v=1; x=1787559928;
 b=LOyqKIP8U/DmD1VoXOueW2cNHTUY3/mO+breI1tQhH1n/PEE4g8zlyymbMmdIYFnFcrv6RvC
 pVvzJcfFBnQDqpvY1sCEcQN/mBN9OQtSc2BU1Xz7W+DoGA3BCDQYWKOezSiLUw8E1W5e2I7LTZe
 wbwmY96SzDjJiffKJm3Ai8SM=
X-Envelope-To: linux-nfs@vger.kernel.org
Received: from localhost (3.112.29.171)
	by mta10.migadu.com with ESMTPS id 5d0fb72b720b7f63;
	Mon, 17 Aug 2026 08:25:17 +0000
X-Migadu-Flow: FLOW_OUT
Date: Mon, 17 Aug 2026 16:25:14 +0800
From: Baoquan He <baoquan.he@linux.dev>
To: Lukas Wunner <lukas@wunner.de>,
	Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <contact@jaseg.de>
Cc: Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <linux@jaseg.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@kernel.org>,
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
	Ignat Korchagin <ignat@linux.win>,
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
	Simon Horman <horms@kernel.org>, Eric Biggers <ebiggers@kernel.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>,
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
Subject: Re: [PATCH v2 01/13] kexec: add CRASH_WIPE_SECRETS to wipe secrets
 before kdump
Message-ID: <aoLFai0gzzH2bGgy@MiWiFi-R3L-srv>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
 <20260811-crash-zeroize-rework-v2-1-9561d13c2340@jaseg.de>
 <anw9ILJiO5xIjP4f@MiWiFi-R3L-srv>
 <9765f7ea-36bb-4c7b-a19b-7facec97b762@jaseg.de>
 <aoGpcczo5GkBsPwt@wunner.de>
 <aoK6jXA-tF9qfKOZ@MiWiFi-R3L-srv>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <aoK6jXA-tF9qfKOZ@MiWiFi-R3L-srv>

On 08/17/26 at 03:38pm, Baoquan He wrote:
> On 08/16/26 at 02:13pm, Lukas Wunner wrote:
> > On Wed, Aug 12, 2026 at 12:08:39PM +0200, Jan Sebastian Götte wrote:
> > > I can imagine one alternative way to approach this, tell me what you think:
> > > Instead of registering wipe handlers that memzero places on panic, I could
> > > put an optional registry of (addr, len) descriptors into crashkernel memory
> > > that the original kernel populates with the PAs of buffers to clear ahead of
> > > time. Then the kdump kernel could do the actual memzero. This would remove
> > > all code from the actual kdump path here. The registry could be made
> > > per-core to avoid locks.

If this has to be done in kernel, your (addr, len) registry idea is a
better direction, and we can make it a bit more general.

Instead of a secrets-only wipe registry, consider a small "crash memory
region" table with an action per entry:

enum crash_region_action {
    CRASH_REG_WIPE,   /* memzero, then dump normally (leave zeros) */
    CRASH_REG_SKIP,   /* do not include in the vmcore at all */
};

struct crash_region {
    phys_addr_t addr;
    size_t      len;
    enum crash_region_action action;
};

void crash_reg_add(phys_addr_t addr, size_t len,
                   enum crash_region_action action);
void crash_reg_del(phys_addr_t addr, size_t len);

Two actions because the use cases differ:

- WIPE is what you need: zero the secret, 
- SKIP covers things people do not want in the dump at all
   — Registering as SKIP reduce dump size. I have been considering how
     to shrink vmcore size on some big system with huge memory, the
     vmcore size usually is several or tens of GB.

If this is OK to you, you can start a regiestry table
infrastructure with wiping secrets, we can add SKIP later and plus some
driver used memory.

I am not sure if it's satisfactory, but you can give it a shot to show
what it looks like.

Thanks
Baoquan

> 
> Since there are a lot of security expert in CC, I am wondering what's
> the risk if we wipe secrets during dumping. System is located in
> user's place, and vmcore is dumped and collected in user's place. If we
> filter out secrets memory when we dumping, what could be leaked out?
> 
> > 
> > Or create a dedicated mempool from which all sensitive data is allocated,
> > then call mempool_free_bulk() on kexec to poison everything in that pool?
> > 
> > Thanks,
> > 
> > Lukas
