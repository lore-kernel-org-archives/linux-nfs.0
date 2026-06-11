Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F37C640D585;
	Thu, 11 Jun 2026 17:31:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781199066; cv=none; b=AAF156L7zGzcDIk4ocZdGUyAWM4JWusPxNxtY1+4T5O9ad/X/4R6KJVF01LqETEm/wfeQEhx79NzG4vigkPyY7x0QoA7Dsp1QjRvjElDArp6nkCqNsIrmlJ+YQOf+DBdhwILggVR/EPGY15J9NCoWFvQnbjDXCFd5qveAAKmxeg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781199066; c=relaxed/simple;
	bh=3v65/q5WcsjJD3zNFcCxjQ3wajQxxQ01TpLu0g7i4Ak=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=CY/61CVlI/1kP6ZAKDsSBt0d6dEWI/ih4NfQrSzgiqyZxLbrHK7LvGAXVn547m4sgXqRpYqSOgg8RZG7gBDbLA3LqSRTkWDVG/yRAFAnRtpE4MH6aGLWbKy5cdttsVZs2tuZkhr0mZvJ53M7rB+1UUitz+OS7B0XLIPwzKfgpZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fQsmNBxL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fQsmNBxL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2B7A01F00893;
	Thu, 11 Jun 2026 17:31:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781199064;
	bh=tgsmiHSdX46c0MwHeH/XSmXB4qm5+uLMh56BNRp2GbI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=fQsmNBxLkvs0d98A8GPz/squQVksBCxzDcr942/lZd1FXkHDEzUBRhSzt2ZV4Hnpx
	 IJEiEWYSiwd9ljMAVQn+V1YB7PKiIgvnoklZhQIoQpix0Xi6qUTyu36UdPHzzouBXl
	 pA7FZ8lOVZxdbIL0bs+osaw0ppxOcP5uhIy1rBj1SUdXuhGofofpZgP2dXMQLsjo27
	 nPK0c60CjYebkCuH4DYQb3KPEWRQGJfEsRgNpKVFO/COM6NPIw3kyjowYQXJvQUZ3z
	 EQXgpUxglytB/kd4/yUkqiEXxz6a2J15eeR7ErPhQqjnVLtCkyC89KQXYB6cZivmw0
	 iNUZpgmohfRww==
Message-ID: <7e5031b94df2e3d7fa977ee06242c1cd5c4db497.camel@kernel.org>
Subject: Re: [PATCH] NFS: fix refcount leak in
 nfs_direct_write_schedule_iovec()
From: Trond Myklebust <trondmy@kernel.org>
To: WenTao Liang <vulab@iscas.ac.cn>, anna@kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	stable@vger.kernel.org
Date: Thu, 11 Jun 2026 13:31:03 -0400
In-Reply-To: <20260611150354.90801-1-vulab@iscas.ac.cn>
References: <20260611150354.90801-1-vulab@iscas.ac.cn>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-06-11 at 23:03 +0800, WenTao Liang wrote:
> When nfs_direct_write_schedule_iovec() fails to start any write
> operations (requested_bytes =3D=3D 0), it bails out after calling
> inode_dio_end() but before releasing the dreq->io_count reference
> that was unconditionally acquired by get_dreq().=C2=A0 The normal
> success path balances that via put_dreq(), which decrements the
> io_count and eventually calls nfs_direct_write_complete().=C2=A0 The
> leaked reference prevents proper cleanup of the direct write request.

Again, I'd like you to explain this claim that somehow io_count is
preventing cleanup of the request. Neither nfs_file_direct_write nor
nfs_direct_req_release care about its value.

>=20
> Add the missing put_dreq() in the early exit path before calling
> nfs_direct_req_release().
>=20
> Cc: stable@vger.kernel.org
> Fixes: 65caafd0d214 ("SUNRPC reverting d03727b248d0 ("NFSv4 fix CLOSE
> not waiting for direct IO compeletion")")
> Signed-off-by: WenTao Liang <vulab@iscas.ac.cn>
> ---
> =C2=A0fs/nfs/direct.c | 1 +
> =C2=A01 file changed, 1 insertion(+)
>=20
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 41a6cabb0592..99bd72a4601c 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -956,6 +956,7 @@ static ssize_t
> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
> =C2=A0	 */
> =C2=A0	if (requested_bytes =3D=3D 0) {
> =C2=A0		inode_dio_end(inode);
> +		put_dreq(dreq);
> =C2=A0		nfs_direct_req_release(dreq);
> =C2=A0		return result < 0 ? result : -EIO;
> =C2=A0	}

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
