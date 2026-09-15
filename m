Received: from mail-ua2-f12.google.com (mail-ua2-f12.google.com [74.125.226.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1ADE42750F2
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 16:01:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.226.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789488067; cv=none; b=DkuOrFlcfGg/LvirGskSjs/u+ir6Sdy49KMbL58HO3pOMA7SAqqMAe/5kqjlC7vHbNS1xJVB7U81CWj9ukD5/ch0vrGRsv+H2+IeHS98tZDMbVQgyCCB7Lv7i4MJjfDf1XUReBu2sfvJEsyqvY1rqoc4m1Tc0AB/kkST9S6M7Pk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789488067; c=relaxed/simple;
	bh=TP8vzZNqYTvpqyiQsP8/kzXcvof+WkIv9WsLTDcnXlU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=l77P59YSfY7R3iCEjUyqsvv6ZRPE9aNt9BCl05gqH6uc2ZUTUqydPH9C1/5mkhSPLArmNDEeeCYJdZ4o7w5Bro8uuLvu6VfJ4eO/1EKbcrJ0Iq32bq03i4qkMxxkbDl2Gbw3c8XaYL+Xn6dg6tnF1JBn4B+KubLnxoG4/CKBgX0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PgNDW5/1; arc=none smtp.client-ip=74.125.226.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PgNDW5/1"
Received: by mail-ua2-f12.google.com with SMTP id a1e0cc1a2514c-97e7c72bfe9so785465241.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 09:01:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789488065; x=1790092865; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=kHnSyuLANDxKOE15RlXzsARxBU9yDC28z60+XrDSb1o=;
        b=PgNDW5/1++gfdfkWd8E334FRbkdy7GHOa3tyFNmXzjuT6ndnKM0M1WQLDa4RRY3wkU
         xSifHRlOj3cNv87VHVspiP2uuiHfqwUyaWHGFZDHDux9TkuFZqZLrK2iHyiyfYF6XRM/
         Rl+Xq/dsvT4nyyRxyZnvrKODwL6NsvO8v9rnIY8kjvtnZNM9UGJw4ETBJzN4++lM083G
         ASwWHMhgmLIkHCLgDhM//9lchCnW4oWIat6rvzHgicwWvszFYg0no3daVSToEefyU97M
         Ds2HT7qSjw/IP0LDdqrMMlgzbKu1W8P6W9WaPDF/SGp0xNkwOb4kk20wlfi9Ve1xwvZp
         EmUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789488065; x=1790092865;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kHnSyuLANDxKOE15RlXzsARxBU9yDC28z60+XrDSb1o=;
        b=T+TOC4is4mBViNlGAf81djtreCUyLK7sqmt5YsGkX03St7ZEVecwy0xiXsRdrvm8Hg
         0p8THA+o1RO9Jzv0Yw4xCLNWpuDG7/dHVxHt/aSru4cHwC636MSybmvLpPiIYBsLQPnj
         +A366tA9Q6BNNr/E7jxjsY2FbXie7/himaJWGbp6xwbCKtNDbaM24D14ymAAOO48lKZL
         w8nDZ4fxOwjZ0QKSb0AiJleW2RlgvRgN8oGdLvKJnb+ouumtQH7YpEn4a3KOYsp9Shj3
         93eO4PGrey1gbyLUe6q8GiTcktGeva6TIJ5qSyDkq7T8enxxJHGYCjIR6o4GaYtISvkZ
         YfSA==
X-Gm-Message-State: AFuF++m01jiwfPmp22v3iGyCbD4Sk39TARgC/+6KI8+uRv0GpPtnv482
	N5mc+HrbpkLlXPVG5duFPfTYMeuiWR3xUNArnDL5c7CmRSWP93rWRNal
X-Gm-Gg: AYBFou1vzVTJtp12lxukTIp87liWryDEal/wQLANBW5RHlyFFKDNLnnUNZK88ywYJl6
	IButYvLPyLUcPUpD6ItObjLWYlEOiXpzRS9LGuc59LGE4ExulDPohcPpwvY8uZGnhwc11tpguww
	i6aho9G0d5YvPLq+z79S394uopZCA69aw2BhBfL3hql/8lmFx9QW4c2OOA1doib/vl+D+eNftMx
	sEkvdxsfDc9HlakfdKzhguLH9fYs9oiAvs9+Fhw4zs2qCUJUo90kMYgto0H6ba/qnpWSTd/K6rJ
	Xt2p9lFuNBb7wEv4XyPI0bZfepmFpJvJbp3kNjB0NZQiJ/XEd3cTkN1kSwDE1/1x/0qMRexDEBU
	0GP62RWhMfwzG1lw6sLsFDE9RWG3SXklHuvkdBeZijY1PPrl93A1WpkmKHcLflk49PtgHCovucE
	ZCnKx9AiEPT6zolBQCXBTnwhu0obCUVCA0rWcdr/wZ+sotlncQ67KClFpmYRzBHZ26
X-Received: by 2002:a05:6102:a184:20b0:79c:cf1:723d with SMTP id ada2fe7eead31-79c0cf17cf0mr7667253137.6.1789488064765;
        Tue, 15 Sep 2026 09:01:04 -0700 (PDT)
Received: from beelink.. ([187.13.206.89])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-79fb1148f57sm79049137.4.2026.09.15.09.01.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 09:01:04 -0700 (PDT)
From: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Subject: [PATCH] nfsd: zero NFSv4 COMPOUND tag padding
Date: Tue, 15 Sep 2026 13:00:49 -0300
Message-ID: <20260915160049.3105481-1-qwe.aldo@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs4svc_encode_compoundres() copies the tag bytes into reserved XDR space
and skips directly to the aligned end of the field. xdr_reserve_space()
rounds the reservation up but does not initialize the padding bytes.

A remote client can choose a tag length that is not a multiple of four,
causing one to three stale bytes from the response page to be returned in
the COMPOUND reply.

Use xdr_encode_opaque_fixed() to copy the tag and clear its XDR padding.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e17488a911..9377f42dfd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6480,8 +6480,7 @@ nfs4svc_encode_compoundres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 
 	*p++ = resp->cstate.status;
 	*p++ = htonl(resp->taglen);
-	memcpy(p, resp->tag, resp->taglen);
-	p += XDR_QUADLEN(resp->taglen);
+	p = xdr_encode_opaque_fixed(p, resp->tag, resp->taglen);
 	*p++ = htonl(resp->opcnt);
 
 	nfsd4_sequence_done(resp);
-- 
2.43.0

