Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795196782;
	b=KL1jK1S9TAzc5KDbVXqfM1AoSAnH1XTyNVr+fFGCwyosvkS61et64ClbZmvKfNG4GAwY
	 CkV2+nI2qRqFxB+knAC32EtX5OYfcjnEIMma821LoROEddOCK2YDVWCEDiZLkaDadFNst
	 gkSYwzTroAAcULM1sAFjhts+dYxlozcFss9NlgTR2v/KDj4JA336WMfEdQTq2M0ahQqjA
	 LQgiJM5IM7sxXKidIR1LEibkadS7zkWiAhvYyMqVqm4JNX+tKP99c4k9dh9g5I4/lGjPr
	 Hcc0BLv5pgdUeb0+JmyDPb/Pi/oPrLQvPkCIIzl/s2EAKIimIGMOskMARYovbCPtjpA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795196782;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=MzHBbgRDEFuttPDrU1ZteS8Kii9tDuA3bAhFvFSydEk=;
	b=5QqpXOoegm/ujqSRn1Wwvly9o192n6tiqMj596icDRp7WG1GAYEukRdFgkX8SXUyNjPo
	 p1OudrvS4frswMGI4JrkIJPZhp31NbV9dGJ/Mq8vQ/ytuIUIh9gr60u77DuWcFFRW847g
	 LCi/A0vBFuflcU79GdY/vxn3dfeg0CmcmvF7top00Xb/zDme26/KgBUIekrl/DP7OkwHd
	 G2lkWVdwUu23cx45XfWcvZ1d4X9Nn6/3PIjEqKXljQ91T1u9pEiLa3b2tfj0u5QziIGGb
	 gfEQD+FK1iW/12GR5ahEMJIl0vYsBp5rOo9JAP8xcf2SlHNN8ayFUqbokoLpYd7zaig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T6cWnafP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 275D160A2633
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 17:46:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=T6cWnafP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 54EFC1F000EE;
	Fri, 20 Nov 2026 17:46:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795196781;
	bh=MzHBbgRDEFuttPDrU1ZteS8Kii9tDuA3bAhFvFSydEk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=T6cWnafP3CTZ711CyKmlVuV/zgUT60HvetgTJH/57JAGDaHg4IiyIGgyH+K4DAOtT
	 +P9M6fuCLAmawcKjz3JmNv+sBGHF3JdAJqiwOJ/jLdAuK5f7EFuK5y8WUt8gx87xky
	 o1zUtS4KUUdvYFP8LbRW2HxaX6Dsk/YofPdYe2O39KxT6vW+F7a2ymPo9nHWie69fq
	 zQcUEfDWT9KWJej42yx+VextoxlVAPbcGtdCoM774/hcHw+QnSf5qq33I25vOc5pmi
	 ih8ApjbBNnm09qphVswyvypfJOCf5nBc8Y3C9gXdPlyFYfO6YBDHSEODutCvN2i0xy
	 Epi4j4ZYwCkzw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7A4D2F40066;
	Fri, 20 Nov 2026 12:46:20 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 20 Nov 2026 12:46:20 -0500
X-ME-Sender: <xms:bIcAa2-XLJCtRWRqqwJc63DaYI5iZOP2W4iRiFpyHcnkIVnEZyWXYA>
    <xme:bIcAaxgI7SqF6vIgbG1u3f-sSaR-PLbShGjXcqnv25WWRzRB_QuVYYLonOoTDA8v5
    Ccy68lMKNrW1yGJcE7REyIELDtRZX4zIhgYT6QIyssNr61P29S8BUxX>
X-ME-Proxy-Cause: dmFkZTEOhGAK0D931TFCN66rO1Hos/JxqOYkTuFjqKcHmKDgb7JEToAraz1e/M6AKQwZ1h
    RbPe7sDSIwVs4DXrSnpnd3gbCiaPTdZ6mr9L5XiP/LSa/XO8YV3tOPSSCuaReNFh7M1NPO
    46/gzDycvk82FAEKs6ihFkDJ1Rm3bDj5+XFEnq5hIRnD1hLWwFscYeL6S5mGPcnX60SThB
    0pkYZ2wiVcbwW3kploVcur54hoiv+E88cQcNjLr1GEjK3p3AHjMqo99mOyVrdJoW8SjpY/
    ygFPokrIMte0mnXs0+A6I0T4QP36F64yGKrDuJQtdyeHYvYedopWzqKg7GzHSEg/O/BqoC
    e5mzWkNViDAd+OrpHo18DR7qKN/g2xOZbTUp823qnz6jjANg/8iLt4I4o2szxu7ZyzOr/j
    TgVAVy7p6X8O+XECkxsIRTpyhCLJQ9fodDntn0IWbilmVbO2TjRynLKvRlg0BeC9nWdNpo
    BVfztcxP9H4C9agMk9iFEWoxsqOwUYOmvnCYGqm4OcmquKHgVlCE6aPYONBKIGE2WiQWeU
    1oTjnVkoGyHFJWNN8wHHvHiDChXI8pcom+DmoO5tUM6FVc5pdN30N25peKDx1ECUZF6etR
    KhkLl+eCrNk7L9VzYyREBU1vMpoMKkzp3jOeysw9phzMRdy6vEe8R6lUzUQA
X-ME-Proxy: <xmx:bIcAa8TCnhAy0n81mHLGH6MepBDgXqwWHxnE4B4n5czWCjhr5Mr2TQ>
    <xmx:bIcAazwjLrCdEaZKebIi6DDlIvBnqOFFvW0jPZqncqcyKNN0TduRnw>
    <xmx:bIcAawd32yKs0dLSkSbbIs9Yt5eLgadbKYFpxUAJoYItDvhc5ZIk_g>
    <xmx:bIcAa-P1jbH9WP55N-gRvkCQxLHQC4t3GZ3WeMJ4sOVw51oXJx4NnQ>
    <xmx:bIcAazv0Yi7oecpIIumKxBbvt490xRQhN1u0fAvs3n8P2zAf4zpP4YdJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5476C780070; Fri, 20 Nov 2026 12:46:20 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AGH3eQqJI8JV
Date: Fri, 20 Nov 2026 12:46:00 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Dominik Maier" <dmnk@google.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 dmnk+artist@google.com
Message-Id: <1384e278-1c37-415d-a46f-314b6619e545@slotpi15m67>
In-Reply-To: <20261119192331.2695154-1-dmnk@google.com>
References: <20261119192331.2695154-1-dmnk@google.com>
Subject: Re: [PATCH] nfsd: enforce export checks in nfsd4_restorefh() and
 nfs4_check_file()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, Nov 19, 2026 at 08:23:31PM +0100, Dominik Maier wrote:
> When an NFSv4 compound saves a filehandle from a UID-squashed export
> (all_squash or root_squash), switches current_fh to an unsquashed export
> via PUTFH, and then restores the saved filehandle via RESTOREFH,
> nfsd4_restorefh() duplicates save_fh back into current_fh without
> recomputing the worker thread's subjective credentials via
> nfsd_setuser().

Thanks for the report. Both problems are already addressed in
nfsd-testing by fixes that went to the list earlier this month:

  9bfcc9001962 ("NFSD: Apply the entered export's credentials after LOOKUP and RESTOREFH")
  e98bd0f51645 ("NFSD: Check export security on the COPY and CLONE source")
  ba7c5a136a13 ("NFSD: Use each export's credentials for the COPY and CLONE stateids")
  305bf9791dd1 ("NFSD: Check the secure-port policy when entering an export")


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
