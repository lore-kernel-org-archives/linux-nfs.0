Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795134851;
	b=QfmgCJcuWADygBEUbRHscKBBFVwH96J9Z33mrhtvulSWw/ugnhHlxYOVQsFsx+S1WlWC
	 hIw7ghF49SHEzR1jQIh04KT1UrZ/bvVWXvP1MbxSMk7Wu/kG80QwUfa+OE+ZaQ24Fm4El
	 3XYAWK3vQ9NvvDt21/jXXMI4hSc94/k2yL6hsptGorFsvzolxzyDN93hoaST9wWhb9985
	 kpDpphhbIpuCtaP/i171vyr5yFKBWr4QGOKr73cHZbRqaJsup+2sYGVORgC4POrZoWYaS
	 tK/BZY+WRZGnk1crHWEG40deWP0FjVaEwH1bicO6+dEJLS5cjuJdw4apuiXoV66hegg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795134851;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=rd711GT9gGb6CJo3rle/g1OABwW02eaAZ7mhcHjQJnk=;
	b=oHrVP/Z+wGKq1txgi7XpJusTTKj7K7olUumNPkMSqdoqy5tb4hp6nXf/EeHpECiRFzQk
	 pkFFHgCJPqTRQY+G45heKJZCiQtMbODoflNrv81Yb3HGQxP8t69s6d7lChMdLVJV/CpfU
	 8htMyCk5EgdJz1Z3Y//ZcoXuoEDDFkNKz3JFnQjl8nO5WAWUK4uIsV4NOS7kXvO+Gzywn
	 FNgHcxuNm3upnMrCG4goTc0/fCOdcioqGq0byfHbV2iG+Vamr3aiZLDpuQFpqIpvx7FD5
	 ecemtD7XydaPbrBW8J9VMZnxZJzznU7O/tLGs16O0jBCvX/jnWm2ZNzQW+rC+XrMEYw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c8wuEy2c;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A34A0606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 00:34:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=c8wuEy2c
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B15B91F000C6;
	Fri, 20 Nov 2026 00:34:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795134851;
	bh=rd711GT9gGb6CJo3rle/g1OABwW02eaAZ7mhcHjQJnk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=c8wuEy2c3V8aTX6d4vlmotxwydex52gn4P1VRhEpSUOoSqqFWncqa9ykyksb/gkpQ
	 jAl6xHAbl1DIeO3gNFLHD7B92ZjNF+TcgCVIlHOLm/SkpyoArwHMCoprXGk1h2bVQj
	 38ZLhW4+w46GIgdp0Igj+M2dyy39jyw0rPutu8zCkxgfrolcz9tbmeT4wsb0pXcorU
	 llzEntjrNgy0LRZqLVawJzSPXtNLFN+kNCaK+g377mHD0qZghWeuxSAr0/NFbDfmcP
	 8VJlU010ltkmyj92bmVS4/88UDiO8n5JCZd/4tmfxpJuJZttPGwYmtKwrpaxpDRLGe
	 R+UCuM0Wrd7sQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DFB07F40066;
	Thu, 19 Nov 2026 19:34:09 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 19 Nov 2026 19:34:09 -0500
X-ME-Sender: <xms:gZX_akfpROVcluRnJt5S7fcAR9hcnX1LxZ9YFFmpSH35tzpiTKvC6g>
    <xme:gZX_ahDx7wIfIoIzbhLmVc3QnCE0vAYbU49H1DSgxjH2fBTvteSxlw83HFq5iO39P
    9vWFiH-6BC4fJD1T1PDjALL6tc3JpVe29MbDclehU8ubFBN4f1J_T1S>
X-ME-Proxy-Cause: dmFkZTEgyChi6FzbuuEENfHWBkBs4VFC5ERztXchi0AVYFjuUtpPNwAKA7pFy5tjSMzGXV
    OfaHtEts1YafiZQ0KYs4kVE9W+oc1ZCYV4I03xWpfF3fWkgpcRwkJCkqBK0+Qav77t+LBd
    qN1uFJoI56gNcA0T3muoJlI0U4kVuh0IQfFZEYo3AYZc+JCmKbV3ejR+iKt/lTRTN0c+AW
    /1hWUuDs7r4vVB/1TslK9IkPeEpfoWNN9+GcksoMywDVQMwkG3D0FpyFIzwAgwbQ4RkP7X
    Xv6tZXdEzOAaJDvSNLf1MwblEVwg72lyHCjgUx1T5zDBikeN1wZ96kE6EOjxcs2+159IHy
    v3cRA+45PPk58fbN6woD/uxrYhBJ32btluoJbWkrnYnNH11n93IQck1xP38iWWTVcvFtzq
    /joY8XxUCg/0wROzBsmhNuz1hfa4V5W1bWrEnfHbAedzHjrrxUV5QK7puiiKPY1HuerdrW
    h/cjevbMNAUQpvXf78xrESBbYazgR/LJ2ig1EYkXXvYvskTDCxccASDuucg2MmEWdMkAXM
    XqvJV7IQfEEzOD+/fGQWHETEBU91hK22Paf0dOphA4BthAbHR7FnQ1WZjDzOL09bjFhqN4
    pnmOUyaCK8+WhH6d6NZxmcPqoqx1nUV1DrnTNsIH/caMO9/3jiXHEye7l+cw
X-ME-Proxy: <xmx:gZX_ahxsQaRCM_lrFAJEgXeVtug3L7zeZ-zsi73On_MKcqFQvc2K3A>
    <xmx:gZX_arRNtR124rXh7ZYUs1eNbRC9sQKPFEJ1r7v9NrcS9yLP7BKzsQ>
    <xmx:gZX_ah9cMGzr_JGGdMjODrMkSsvleczz63oQXBN-KDJEJyiUYTw7KQ>
    <xmx:gZX_ahsRpzJ45jT7lEvmu3tJ-7Y5_5bLMfavkGHoH0upk1Z7XAUxjA>
    <xmx:gZX_ahPbJ1yXf8Q9UmqWBBLGsVDt6FAzcggIF-cz1CEi00I2OTxGI5Ka>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B1D03780070; Thu, 19 Nov 2026 19:34:09 -0500 (EST)
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
X-ThreadId: AdKDByzONJ_7
Date: Thu, 19 Nov 2026 19:33:49 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Dominik Maier" <dmnk@google.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 dmnk+artist@google.com
Message-Id: <310dc7cc-bc8b-4307-ba62-5872e5adb6c0@slotpi15m67>
In-Reply-To: <20261119192318.2689409-1-dmnk@google.com>
References: <20261119192318.2689409-1-dmnk@google.com>
Subject: Re: [PATCH] nfsd: require NFSD_MAY_EXEC when acquiring directory delegations
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, Nov 19, 2026, Dominik Maier wrote:
> @@ -1475,7 +1476,8 @@ nfsd_file_acquire_dir(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		      struct nfsd_file **pnf)
>  {
>  	return nfsd_file_do_acquire(rqstp, SVC_NET(rqstp), NULL, NULL, fhp,
> -				    NFSD_MAY_READ|NFSD_MAY_64BIT_COOKIE,
> +				    NFSD_MAY_READ | NFSD_MAY_EXEC |
> +				    NFSD_MAY_64BIT_COOKIE,
>  				    NULL, S_IFDIR, false, pnf);
>  }

Hi Dominik,

Closing the search permission gap is right, but the stricter check
might change what a plain stat() sees on a Linux NFS client.

The Linux NFS client requests a directory delegation by placing
GET_DIR_DELEGATION between PUTFH and GETATTR in a single COMPOUND.
_nfs4_proc_getattr() does not handle -EACCES. The error reaches
stat(), even though stat() needs no permission on the directory
itself.

Before this patch, looks like that failure already hit a non-owner
looking at a directory without read permission, such as a 0711
home directory. With NFSD_MAY_EXEC added and NFSD_MAY_OWNER_OVERRIDE
limited to S_IFREG, the failure now also hits a non-owner on a 0744
directory and an owner on a 0600 or 0400 directory. After an
access() call on such a directory, "ls -ld" fails with EACCES.

So... RFC 8881 permits NFS4ERR_ACCESS from GET_DIR_DELEGATION, so
the Linux NFS client is arguably wrong not to tolerate it. But
deployed clients behave this way today, and NFSD already has a
non-fatal path:

nfsd4_get_dir_delegation() replies NFS4_OK with GDD4_UNAVAIL
when nfsd_get_dir_deleg() fails, as the comment above that call
explains. Taking the same path when nfsd_file_acquire_dir() fails
still withholds the delegation from a client that lacks search
permission, and the GETATTR that follows completes:

	status = nfsd_file_acquire_dir(rqstp, &cstate->current_fh, &nf);
	if (status != nfs_ok) {
		gdd->gddrnf_status = GDD4_UNAVAIL;
		return nfs_ok;
	}

The 0711 case predates your patch, so I'd prefer the change above as
a separate patch ahead of this one, with its own Fixes: tag, re-rolled
as a v2 series.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
