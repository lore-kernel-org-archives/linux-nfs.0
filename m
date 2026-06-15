Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA864391E49;
	Mon, 15 Jun 2026 21:02:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781557334; cv=none; b=MrjzI4GrMcPiEusIQeWNVOZre7IKtDO3O8l/Txcyqo+lZxuCl0qNACBHQXwNqQzND1VDpXmPOtvG6p1HyOlCquFC31QHvRKet5YITCOq1sZPB8XQlQHM+MtZxfgh2KV4+T/rZq6XhahRwf/dfE42ATyqmmFpTCYHLP9bwniGovE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781557334; c=relaxed/simple;
	bh=s41iXnqBS3EN//qmas3KSAcvkBLlPLobebsrCOnpFRQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=cwAewj/MZVNHrBJyquJdeQG5kFYwSbCuYcLTHu5sY3dCr2LxTD6U2Igk5+XzmsPKTNmeeFIJ4Um489IX5qJctx+XXfMTcwvpkUVRAcXHq+atS9Otax6HFrdg2jdXk76DiUAgQvWDvdIkyVZ+fvLDLK0RKtqVRA6u3yxntl2ASxY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QEIjRu0U; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QEIjRu0U"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F315F1F000E9;
	Mon, 15 Jun 2026 21:02:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781557333;
	bh=Jku2/OpmuiyvPwKyvy69esCM6N0Xy/x9/NMFC8OhodI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QEIjRu0UbsWgVbyyUhFRY0R0TXczd/9DbFRqPfPnBA57oCpbZ5K+jDSJToZFivfvv
	 3sGYaQf0mfj7gsOF2t8apUW08XTKffn6XNk8liX8np/8+pC52nkN7KVaCogTSPhY4j
	 Tn1uu2GbanK0KSzkAPHJm2SJYswDxmy4kVN2XfmNdV7sJCTvoQhTKYOdbMiiEF0Nzy
	 KVRUp1GouqSo3ZKnMDPDyAR8RCVDQAY7UlV992pBBbEvpKMRYbF6WtNUDl2b2cAAVK
	 qe3MGoav/ujJZrvoZrZqycDdiWfuWpR+3UIj5LF+kuijJOcFWaYqAZ0Tqse0pddCuE
	 X4mWxHA4jdSSw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chris Mason <clm@meta.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5] nfsd: validate sockaddr length per family in listener_set
Date: Mon, 15 Jun 2026 17:02:09 -0400
Message-ID: <178155731956.328534.13401607491444151302.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260615-nfsd-testing-v5-1-188d75aedda0@kernel.org>
References: <20260615-nfsd-testing-v5-1-188d75aedda0@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 15 Jun 2026 14:31:25 -0400, Jeff Layton wrote:
> nfsd_sock_nl_policy declares NFSD_A_SOCK_ADDR as a bare NLA_BINARY
> attribute with no minimum length. A CAP_NET_ADMIN caller can send a
> 16-byte NFSD_A_SOCK_ADDR with sa_family=AF_INET6, causing a 12-byte
> OOB read across three consumers (rpc_cmp_addr_port, svc_find_listener,
> kernel_bind).
> 
> nfsd_nl_listener_set_doit() also parsed and validated each listener
> entry inline in two separate loops, interleaved with mutating the
> running listener configuration. The validation was duplicated, used an
> open-coded "nla_len < sizeof(struct sockaddr)" check that was too short
> for AF_INET6, and handled a malformed entry inconsistently depending on
> which loop noticed it.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: validate sockaddr length per family in listener_set
      commit: 1f102d9ff00620b845546051ad1ee57976f2db88

--
Chuck Lever

