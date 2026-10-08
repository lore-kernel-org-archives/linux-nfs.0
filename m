Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF25E346766
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:24:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483851; cv=none; b=GFBNxleQX5GpTuUeekkIIumZsyJymlwtZJi37zl5tukOKGcprTPl25gMnWrXndoTkBVcdXBcg0OrQyp8ECBiQ88cQ4oUrV4VgwaMFDTU689h0PEV1PlrF6ZOAUrhBETiF1nnwq+gaoUxgmhuB2OQaztqNMLa8eiYjqCUE/0LtuY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483851; c=relaxed/simple;
	bh=K6JHaO66qK24Ymgq3r7aqbZjCNw56+/2urWNdMMs+4Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=qE3DcP7ctinhG2SR+uDt9+wS9HLisg7j+HprKHZDCMLrkhX8vslJOBlSDmcAc2IRPPE+ieEsdc9OdZyuVb4furpclacQC7k64FPQjgsPEwcsVbhA3vNV7hQavAWiqTpr5tbpClCKAOwsqs1EPsvUraHBj7TKelEcY4VpxpUHQnQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=moZ7Dpaa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="moZ7Dpaa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B1E451F000FF;
	Thu,  8 Oct 2026 18:24:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483849;
	bh=xj1Unse2cOPibr03DC20sQQlmFjI452QPQIfm6PE37c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=moZ7DpaamhjrTn3elVswGEyfmSnViU8cpCrwGc6P1g3un7PYQ0qmryPOkXBiJdPjj
	 MIJ0Fb2FIetmw3psx1s+q+XWuEyEXD51zRu605dDHsKAmjcv6f1O9xRgW8Nm92h5Xm
	 xWOiW7+v4HFsrMAt1LBMiVBiBjk3/ezjJxSMuIb8CN71c1W+oGdfSvo+fUltKjCcCc
	 Edfhn97WF0l6MVmkAFJJdXzZ7WS5qezTLuhSv+5OT+2b/tdwGJruRHLbqX9Ixsa8Jc
	 NxeMlVNMCxLyMHDVLxTa2ZlxGALUNZI5nkbQFcGz1ajZeGT6eizX08ViA37k4kVU73
	 6/jkIBAUESQgQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Marcin Krystianc <marcin.krystianc@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: reset the svc decode stream after unwrapping a privacy request
Date: Thu,  8 Oct 2026 14:24:05 -0400
Message-ID: <179148383764.80962.274201296352146254.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261007204917.1818086-1-marcin.krystianc@gmail.com>
References: <20261007204917.1818086-1-marcin.krystianc@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 07 Oct 2026 20:49:17 +0000, Marcin Krystianc wrote:
> For RPCSEC_GSS privacy (krb5p), gss_krb5_unwrap_v2() decrypts the request
> in place and then removes the GSS token header and the confounder from the
> head iovec: it memmoves the plaintext down to @offset and subtracts
> GSS_KRB5_TOK_HDR_LEN + headskip (32 bytes for the AES enctypes) from
> buf->head[0].iov_len.
> 
> svcauth_gss_unwrap_priv() only accounts for that in xdr->nwords. The
> stream's xdr->end still points at the end of the head as it was before
> unwrapping, 32 bytes past the data that is now there.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: reset the svc decode stream after unwrapping a privacy request
      commit: 97bf905e837e345107c2ed3efb2e65108e081e0e

--
Chuck Lever

