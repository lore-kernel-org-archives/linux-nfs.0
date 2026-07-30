Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A8D547ACCC;
	Thu, 30 Jul 2026 23:34:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785454500; cv=none; b=iKReFe6FW2xw3IqektqBu7uK1uIY0OFq8hB0S0SvkTlY9XHKbrgooggXs85uc0lafGeYMtUCNMxgSJoq1EB2cCqZJ+DDYvFhZAdvGZZIN0ydaRaHm0YCwPGVebCcGXVyrEoU/YlZJKie1AieZKCB/fv/HSUfq7FfAZNfQ0rfNOc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785454500; c=relaxed/simple;
	bh=7szWBCWliNIfa9P0jgOL6UQz8fkkJS46bBuSRJc9xVI=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=CIWGkWiC8g/1iEU2soPbVjNwYau3otnEl3XbVk35xdQ/Hocb16oztNkY/xTa9pjRKxIuGhmkrXrI/M+JGwypdlVOdR07gvzyeD55jndNYufnLESTHhyD85SQJSg1EsXCN89xi9BM8xpGTyHqvkrotH51OWCvbITCCr/UPZnK0I0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GRF474Dn; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GRF474Dn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DC5BC1F00A3A;
	Thu, 30 Jul 2026 23:34:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785454498;
	bh=7szWBCWliNIfa9P0jgOL6UQz8fkkJS46bBuSRJc9xVI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=GRF474DnLDrD+DZvl8l2pI8gcRARpsmpsk2kzoyvqc94P1Y9ieW2DoBx2ffCBuhO6
	 RGDNrdItN/knHa9+s4HsgscIJkh3O4E+J9U9dLqTxn9V/yywiQ/h2GabaoqDkavay7
	 EZwP8Bzf6Hq/08n7oPIjfYn/t1sQnHZ2p7ojbIcSUpFkbDMxjpw9PZgG6wHvXWFGkv
	 yLzNmSfiGc+AGbgpP9JY4c7RgUAH1ALK3pgNCh9YpYyCkNhvc5RX6Ah83rQHxWFC7v
	 j4HEZNI1sUo2IWl2edG0cHJY1arZg6MX7omvvmO1OAECtu/WZsbKHpVQtwvb++v5tf
	 J7JMqDuO29G1w==
Date: Thu, 30 Jul 2026 16:34:57 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Cc: Chuck Lever <cel@kernel.org>, Paolo Abeni <pabeni@redhat.com>, Simon
 Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, Shuah
 Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <20260730163457.1105fa69@kernel.org>
In-Reply-To: <amvZraHU3n2sQts1@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
	<20260728185124.72e421c8@kernel.org>
	<480a8337-a91e-40e5-8dbd-d165599fba4b@app.fastmail.com>
	<20260728193058.7f6b453b@kernel.org>
	<a6fb364d-8344-408e-bcd5-0cee4ffabdc3@app.fastmail.com>
	<20260729163142.4f41484f@kernel.org>
	<amtcwSO24GGq_qd0@krikkit>
	<20260730143556.4a8463fd@kernel.org>
	<amvZraHU3n2sQts1@krikkit>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 31 Jul 2026 01:09:33 +0200 Sabrina Dubroca wrote:
> To avoid that, you'd have to run recvmsg-nocmsg/read_sock to get all
> the DATA out, then once you know the next chunk of payload is a
> control record (and hopefully nothing else is reading from your
> socket), one recvmsg+cmsg into a separate buffer.

I guess the difference in perspective stems from a fact that
I'd look at a socket as a stream one reads and dispatches work
based on the input. Not an abstraction layer that by itself
dispatches different handlers for different message types.
