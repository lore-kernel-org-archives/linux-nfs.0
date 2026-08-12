Received: from mta0.migadu.com (out-175.mta0.migadu.com [91.218.175.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB4C140DB2C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 09:30:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=91.218.175.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786527026; cv=none; b=P61s9weL0XGmuyud2zW/1u0OVXzro6uMJz+tTq8ACvpJgDTdJNmBlyjvu6Y8PYQOeAqNz9fbgikV31zOocPDCbdMFKSQoFT8eyC1cv7nKMaXc+v908U4x+infpu23rRFxm2e3lEsZpDRJL3WS4Ty+eofAXDy+qUxWOwdQwP/QRg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786527026; c=relaxed/simple;
	bh=5Hb81DX76S8IAtLPuaQ2fxU+mq3IGFWwbuaXDXn7mzM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=iyHAualu5+tlRWixO28akfF9NHkWZe10gt/FvmVUgcJxd+Q3UFHRjYqaW+vsTb04EuWxt+U4bwnqB68LWUxu60CfjDDHU2UzMOJOS+SA1S/FTIKEI4kknvEYRZRJFtkhy5GUXobB8WCRLBPUUsP2ivsqza4B+4TNFt0reBafhsQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=K+KKG6z9; arc=none smtp.client-ip=91.218.175.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="K+KKG6z9"
X-Envelope-To: linux-nfs@vger.kernel.org
DKIM-Signature: a=rsa-sha256; bh=5Hb81DX76S8IAtLPuaQ2fxU+mq3IGFWwbuaXDXn7mzM=;
 c=simple/simple; d=linux.dev;
 h=from:to:subject:date:message-id:mime-version:content-type; s=key1;
 t=1786527020; v=1; x=1787131820;
 b=K+KKG6z9cIX9FtV4SGWxRFZtkclJ4Ip7BFSWS0p9EXL4lcbba2/pLfi2aZfUuk+5r3CDEm1j
 W6szvLRQ6EhL+a+giwTbBdWM3A40Qo2tyt/eFA104x0TxZSuEnJxPhsqGTe5Au2rrkD2koxtgFK
 /EtO5qN45kjk2sssO05EjFmU=
X-Envelope-To: linux-nfs@vger.kernel.org
Received: from localhost (3.112.29.171)
	by mta11.migadu.com with ESMTPS id 5cf300efea8cce09;
	Wed, 12 Aug 2026 09:30:20 +0000
X-Migadu-Scanner: mta11.migadu.com
Authentication-Results: mta11.migadu.com;
	none
Date: Wed, 12 Aug 2026 17:30:08 +0800
From: Baoquan He <baoquan.he@linux.dev>
To: Jan Sebastian =?iso-8859-1?Q?G=F6tte?= <linux@jaseg.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <anw9ILJiO5xIjP4f@MiWiFi-R3L-srv>
References: <20260811-crash-zeroize-rework-v2-0-9561d13c2340@jaseg.de>
 <20260811-crash-zeroize-rework-v2-1-9561d13c2340@jaseg.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260811-crash-zeroize-rework-v2-1-9561d13c2340@jaseg.de>

On 08/11/26 at 07:52pm, Jan Sebastian Götte wrote:
.....snip...
> @@ -142,6 +170,7 @@ void __noclone __crash_kexec(struct pt_regs *regs)
>  			crash_save_vmcoreinfo();
>  			machine_crash_shutdown(&fixed_regs);
>  			crash_cma_clear_pending_dma();
> +			crash_wipe_secrets();

I remember when crash_cma added this, we argued a lot about the risk,
finally it's added in with an added note to tell it's an opt-in feature
and risky. I don't know if it opens a Pandora box, I think anything
wanted being here need prove anything else has been tried, and the thing
is very very important. If we don't guard the door well, one day one guy
cold come and said I need ask Oracle database to do some transactions
before juming into kdump kernel because the actions will save billions
of dollar. 

And what does security people say about this wiping? Is it very
important information and wiping is mandotary? There's no any other way
to wipe it or pollute it, no way in kdump kernel? I noticed it's
happening on en embedded target, is it possible you do this on your
embedded kernel tree, but not mainline tree?

Anyone who wants to do thing like this, please prepare answers for them,
and be ready to accept failure.

Thanks
Baoquan

>  			machine_kexec(kexec_crash_image);
>  		}
>  		kexec_unlock();
> 
> -- 
> 2.53.0
> 
