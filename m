Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96D8B560AD0;
	Tue, 22 Sep 2026 15:50:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790092246; cv=none; b=Dj+hQG8ozOu/ACrYSpbPzBSiZFsmkZsDDjHL1iq7C2SzdatNieaWHJYDsdhK80mDuxecjUNsaMfQqtsSl0KbhGEqsCqqcucSdX/go1yDd+TiteVbgTNy8n/mdFsxyweaqoTHpBXsLvR8NWBtFCiXqzF52bz928CbTyyEZqmHBD0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790092246; c=relaxed/simple;
	bh=ciuqAn5+IEN9aHB1AUjtGdOiJ9Zx4Jt7S5Ps4yO+a+M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=URL9RXAvZ1aQyculeCF/n7QklRjgswhyIuVR8+aXU1RsBx7lBWHRuOLBDd/zkf4RquGOKhYnmAq75difzBz0lUMWXe/kfMtPD3bJ1wxrNSozJuaIY1soFdfn5LF1TqmAG1KUF8IjDFaat6dspYZji7nffpDsG2xKTu4wkmqbZ8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GTnWE6Y2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GTnWE6Y2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 243C11F00899;
	Tue, 22 Sep 2026 15:50:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790092245;
	bh=/FHIaydIKTcUBH7Pczn6fA88iewfQ5ilI/ohVhmKyiY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GTnWE6Y2pcK4sGc0veexT5/s5cVmxvjJPwVHLjIX1lJ8GCXx4+gyJhiqZjLKk+kWo
	 NrKBp2YXeCn2/nn9S4sBZyV3wp6+OdfWPVnBYA2v24MCGWWO2vlQsDPMas/C3LNb+z
	 aHuNQS6u09GmTcO7/EsltXlD7SG8/uOeMw1YylnsM35sjpU4009AeLRPTotH1aX86E
	 kleNUBjq+jFie3DATDqN52eZjjpdyxt8kX8+zEyCJMR2eKeLKkdXaVCKFkMqBCDwGd
	 6ENGL0W25aF1FyEyJl0mbbihgfo6iE3j9dFhbqii5PfjQ+YTKHJVzupD/KcG7NyoaH
	 J3LW0qCVLOoZQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	"Peng Fan (OSS)" <peng.fan@oss.nxp.com>
Cc: linux-kernel@vger.kernel.org,
	Peng Fan <peng.fan@nxp.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: use assign_bit() where applicable
Date: Tue, 22 Sep 2026 11:50:37 -0400
Message-ID: <179009210788.3799844.9095882835269531324.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
References: <20260920022714.3145751-1-peng.fan@oss.nxp.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Sun, 20 Sep 2026 10:27:13 +0800, Peng Fan (OSS) wrote:
> Convert open-coded if/else with set_bit/clear_bit the assign_bit API.
> 
> Done with Coccinelle semantic patch:
>     // set_bit -> clear_bit => assign_bit
> 
>     @@
>     expression cond, bit, addr;
>     @@
> 
> [...]

Applied to nfsd-testing, thanks! This narrow clean-up should be easy
to discover and apply as a pre-requisite should it ever conflict
with an LTS backport.

[1/1] SUNRPC: use assign_bit() where applicable
      commit: 1a2b6be91033a31e13b676163be3e232201b1e3f

--
Chuck Lever

