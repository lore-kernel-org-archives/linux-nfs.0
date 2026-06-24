Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79A693403FF;
	Wed, 24 Jun 2026 16:52:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782319956; cv=none; b=qkvMwUFexMt9OF7p6LZQGPXX2m7Fbv6LZIS+oV+DY2qNY7MKtI46HNtM2GKsGvSAmmN/KbdEC/UcvTmMsGbuqgFGf2EgOTrTsPX1mlkPPIJiiUIoTYnUXr7Osb4JyEzOTSkPrfMWlopRBqdNU1cypSLhNhhWDWcqVOYchSAUzdI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782319956; c=relaxed/simple;
	bh=eC5Wtqb/LTJHsD/VbW5QPtvYZoT0SyWymiXngnYjRBo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=k8NtyGo46DK+lp0cw51bLGDT5Yfh1pumQXrg7ONeZUKDDjQh1B8HGU+bEnDHHZzZ4FgQQpW6Lgali+3vjm/sq6NWNZ3wtRDn5qKCXPvjmKdMq7DOy8TxvPK85uQzZzuhanl0CfIxmT1OPycwgI0Eq1k1P8EWmqlbPdmcJAzWXdc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZNk75iV6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZNk75iV6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 43CDB1F000E9;
	Wed, 24 Jun 2026 16:52:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782319955;
	bh=eC5Wtqb/LTJHsD/VbW5QPtvYZoT0SyWymiXngnYjRBo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZNk75iV6f0TJSnB86o/JZDI0zbCdW0v3/eF4E29xKJr5EAH/muFcFAH4n74CGOEiw
	 8volv8a6sNwg94bzpzxiMzt3wLqE54y7wQM2DYqb3N0pBHF1k7VcAxTSm4cqPPvZlh
	 B5rhQOsrhz/F0KNAqemdcThXjM5dakFXa4eDOa1z6grDgjFLwRrne7GRqNjgNfMhUQ
	 UZ/vatWB5UdG8TDkAb12ADQ+ekRlhcvZS5PDbbMy93FsJi6Bl7yqwz54Y3Z/9AgPZ8
	 1myaLf99jkPTH8pjBuev5O0Y1zXJ6pyie377mnIEVxc/391N26jGMAYjQ3UNgP66rD
	 fQM95We4Oi64w==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	Michael Nemanov <michael.nemanov@vastdata.com>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] Fix a few memory bugs in RPC-with-TLS
Date: Wed, 24 Jun 2026 12:52:26 -0400
Message-ID: <20260624165228.2920869-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260504-sunrpc-tls-clnt-pin-v1-0-197f359c6072@oracle.com>
References: <20260504-sunrpc-tls-clnt-pin-v1-0-197f359c6072@oracle.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Gentle ping on this series, posted seven weeks ago. Michael=0D
Nemanov reviewed and tested both patches the following day; he is=0D
the reporter of the use-after-free that patch 2 addresses on an=0D
mTLS mount whose client certificate the server rejected.=0D
=0D
Could one of you queue these for an upcoming release? I am glad=0D
to repost against a current base if that is easier to apply.=0D
=0D
--=0D
Chuck Lever=0D
