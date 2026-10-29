Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793287321;
	b=gLeMiNjU6ubJ15i0mbEfa0k5JAU92Io5ybvN6NK6BKfencixzrXVvo/jHH3vVQMfvhhH
	 +j5hmPI/HQtHKuw3yqmOfv+OSr09A17AR6Yw7hBanzBO0Hrahebh43nQe79NsK22bmuY1
	 yFClTTL0IlBap6WfH2bMYPU5kjZtguir86Qa8BBXWcUQA4fAlcOyrUwgEWO3JPwwWBJMv
	 NGd5A0t8Pap7TaAD9UXJYrdB0OO+cOoZC5rDmNw7HCL7oUNYaAx9NF8smODv+LZNBeph8
	 JyQyR7q4v1iCnnpbeT/gCkTDwnJZeld0AVCxwM4GVWv5TkMsdFrQMrA5uaVseQRVMng==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793287321;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=MDAHO1eflK9N2oBPp6z7e1EXsl8BnH1h5nZqN8C5OKQ=;
	b=0dsBxwLBK13YuVI1pFjXqn4zTKfv/qnwQ/5oFSoYWX4gWHd1VV4CwxsLdUyIFPIFslWS
	 bd9TxmncCVu5B06CU5W72Gd+PwyjmM0y4Fl/fBtBIs0vKMO/UgorIG1ww/VFVdFcAW/SA
	 /dF/0l6VN6UHb+nYwO0qEnHsW3qalyfmBE7CSlGxIgrBG1YU0aChWIx2Jfo0aP9tNWSis
	 1McTeKw00vhguo6moIXjZrju4cOOMc/CaWxV0QeEh7+PN6iV8IylM2HS6EraYO9K6kjPc
	 5LzAbuULHl+QZauZAdeFviYCTWMRgmiOLEmIHF7pc3rpAqehT78BPHAAUyZZ2OaRYeg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YxL7ffUK;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 207FB606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 15:22:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YxL7ffUK
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A18AA1F01824
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 15:22:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793287320;
	bh=MDAHO1eflK9N2oBPp6z7e1EXsl8BnH1h5nZqN8C5OKQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=YxL7ffUKhRo4fYdRS6sK+nTvBfNXMIBQstIFcsXrWmr6QYaR5jxLPVeR5RPLC/M7C
	 KDJgl8YKBVkdqTNtCYQR2FowBctTs8FMcpiRm0sfP3TeDZDqV8U1aHH05GWIgYeyIG
	 crjNymDSgyW+3DNZzGpQoIagkN6ooAJ2Yq2PDqWhVHVGs5lmfWPrlHjzvAkNV4QQaD
	 MMywNOZoWUMpL/lr/qLt6yY82GPjri2JGpnBjjPj3Y1VxDE4eq9yIwXOsJqxxb8vJM
	 5Q11u82/UR6IcL3EUEL2sMNTCjF0zsv9vf6r8QEus5INpzoEQcLWAj68U2gdS1zArO
	 mS6b4HmEiiqsw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id DCE65F40067;
	Thu, 29 Oct 2026 11:21:59 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 29 Oct 2026 11:21:59 -0400
X-ME-Sender: <xms:l2TjatbkolpIsZmAKhdw0jQhEkvJYJKCQWw9GO79ZsTsK-j8Zr9YEA>
    <xme:l2TjavOGylVvgvivz0PpgooYvgPdLAQwS9GNDivtRUyTgPfAiupJ0hYDGxIN42JZI
    noH48RUSZz5akhtv4DA7ooTva7R-iIGLlMDhM9827DZmSlt6UegHAPX>
X-ME-Proxy-Cause: dmFkZTFN/VaiqplX3teeJIaZH0QG1VlR6UUOeukdQLDkYWNN6p1l5h0esCed25mNbBFqG3
    ZmyYtQsmQbNGEV2zdZOdDsCOuGMCVfjnxp4zenMUGDPMO+i4k7aBa1mc2sqAFzJgteP+Tp
    VP5ygBVpaiJcshZ7uM9EI2U1liWotHfcWKJgoSZbMlu9v0r+A3J69QiIK+MrIb2+q3jn88
    LGOt2LFOLlxdsFWvps2qUmlpKCPPSBrP1Uz6jUDh/D01swtkg2bHb4i/XVDLIvSduYaSWC
    o4LA1ieZgxde+MgwVeRwpZN3WFihZDZ2gU9Xq9Cifg5PcvSmQw8CfMsfTMLNEdjGpEQIGW
    ha+bBxWJhhkBP8Owjph+cv8vEJEr7UCJahl1FDymL4m1faxyeCFh8FOKhXOgIKU/NvEMof
    o54LGvKwH9YsFX3FNvA4hz0LCf0yj2Q1Q3AIMXXqxhniiDLv2nfoyqm8A5Hy9CRkXV8Ud/
    OEA2kS5Qan60wSDhRyjFkB38iW7pjkvf5vXWfbs+NG3VE7VhdqxA24QcIKp0KStG56LWrP
    nP9jgEGRiX7yFNLrbKaqICniKqSCmNhtSdB4K3/HMUvlps4+G/cLfrC2fNE88L3L9jn+BC
    quezsTE4aP+zqa7Cf5HuvOr+/ON6FDKIlQA5aOQ5xljyexcfT6Znb+dVzSOA
X-ME-Proxy: <xmx:l2TjanTSNv_5kh5uFIoxlLqEp0rhLxteNQ9BUO_0bUHhDHoNshv_qw>
    <xmx:l2TjapdBCxXOE-Y2J-zHDfVNXlN04cxmstJykvIEPMo0WT27_6251A>
    <xmx:l2TjarBrocM2xfaeeyevVCCaohqd5gTiCWd_fVIoA2F6shgN3ydVeg>
    <xmx:l2TjarlZCIvdzkRX8327HNmqYONPH-ZOtGUOPjUiO6h2zAMRYyPebQ>
    <xmx:l2TjamfFkEtrC_zgleB3fbNXZZUCoCa8nQWmqBbcJ0BKrtExVl5eHNU6>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BD4A178273C; Thu, 29 Oct 2026 11:21:59 -0400 (EDT)
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
X-ThreadId: AOFvRjFAKDN3
Date: Thu, 29 Oct 2026 11:21:39 -0400
From: "Chuck Lever" <cel@kernel.org>
To: VeroFess <coderzeng@gmail.com>
Cc: jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, linux-nfs@vger.kernel.org
Message-Id: <acef1e3e-8c3a-4b8b-9341-5ff0280efa19@slotpi15m67>
In-Reply-To: <20261029063917.138184-1-coderzeng@gmail.com>
References: <20261029051430.96326-1-coderzeng@gmail.com>
 <20261029063917.138184-1-coderzeng@gmail.com>
Subject: Re: [PATCH v4] nfsd: enforce export security for NFSv4 filehandles and
 stateids
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/29/26 2:39 AM, VeroFess wrote:
> An AUTH_SYS NFSv4.0 client can read or write a file on a sec=krb5p
> export using another client's valid OPEN stateid by inserting
> SAVEFH between PUTFH and READ or WRITE.

The v4 revision of your patch appears to combine the original fix with
several unrelated changes to SECINFO, READDIR, LOOKUP, and stateid
processing. That makes it unlikely to apply to the stable kernels
that need the original fix. Let's split the single patch into a
series.

1. The need_wrongsec_check() change by itself, with
   "Fixes: 68d93184352f". need_wrongsec_check() has not changed since
   v5.10, so this patch should apply cleanly to every LTS kernel. As
   far as I can tell it is enough to stop the PUTFH; SAVEFH; READ/WRITE
   sequence in your report. Please confirm that with your reproducer
   on a kernel that has only this change.

2. The check_nfsd_access() call in nfsd4_verify_copy(), which covers
   both COPY and CLONE. RFC 8881 Section 2.6.3.1.1 forbids PUTFH from
   returning NFS4ERR_WRONGSEC in PUTFH; SAVEFH; PUTFH, so the source
   handle can reach COPY or CLONE unchecked even after patch 1.

3. Anything else, one change per patch, each with its own rationale and
   only the Fixes: tags that match its code. These do not need to go to
   stable.

Or, if you'd like to move on, I can take things from here and simply
ask you to confirm that any new series addresses your issue and no
longer reproduces.


> COPY_NOTIFY validates a stateid without acquiring an nfsd_file, so it
> misses that check. After an export was changed to sec=krb5p, an
> AUTH_SYS COPY_NOTIFY using an existing stateid still issued a copy
> stateid although AUTH_SYS READ was denied.

COPY_NOTIFY does not carry OP_HANDLES_WRONGSEC, so in PUTFH;
COPY_NOTIFY the PUTFH already gets the deferred check_nfsd_access()
call in nfsd4_proc_compound(). That check uses the same fh_export that
READ uses, and the PUTFH holds that export for the rest of the
compound. How can READ be denied while COPY_NOTIFY succeeds? If the
test compound included SAVEFH, patch 1 covers it. Unless there is
another path, I would drop the nfs4_check_file() and COPY_NOTIFY
hunks.


> Pass NFSD_MAY_SECINFO to fh_verify() so it skips the starting export's
> security flavor check.

With this change, a client using any flavor can learn whether a name
exists in a directory on a sec=krb5p export. RFC 8881 Section
2.6.3.1.1.5 allows that, and your patch description should clarify
that the code behavior is changed to conform with the spec.

Also, the new check_xprtsec_policy() call in nfsd_lookup_dentry()
returns nfserr_wrongsec from SECINFO when it crosses into an export
with a different xprtsec= policy. Is that not the NFS4ERR_WRONGSEC
return from SECINFO that the description says is forbidden?


> When rdattr_error is not requested, return NFS4ERR_ACCESS for a flavor
> mismatch; NFS4ERR_WRONGSEC is not a READDIR status.

On a pseudo-root export, nfsd4_encode_entry4_fattr() always crosses
into child exports. A client that does not request rdattr_error now
gets NFS4ERR_ACCESS for the whole READDIR of the pseudo-root whenever
any child export rejects its flavor. Could the encoder fall back to
returning the mountpoint's own attributes instead?

The new check_nfsd_access() call in nfsd_lookup() fixes a mount
crossing that never checks the child export. The CREATE paths do the
same crossing: NFSv3 CREATE UNCHECKED, NFSv2 CREATE, and NFSv4 OPEN
UNCHECKED all call nfsd_cross_mnt() and then fh_compose() on the child.
If this check goes in, it probably belongs in nfsd_cross_mnt() so that
every caller gets it.

Longer term, I would rather not keep adding check_nfsd_access() calls
to individual operations. A filehandle whose security check PUTFH
deferred could instead carry a "check pending" state that the COMPOUND
loop enforces before any operation consumes it. That can come later,
it does not need to hold up these fixes.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
