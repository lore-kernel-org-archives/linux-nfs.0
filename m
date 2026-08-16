Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B433038C42F;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786867293; cv=none; b=jqYM/kN2fdQ+j4jvQfJfNy2TQYrt1hK5ew8vbRdLkDGeIPZ8LDi6kCT1ScOVq3O0VwiafWoXjC+Sulu21ZBv1EsMCd2G4xfeDIUVq520LPtAGXZviQmPNt2BZX72FGEoilexSqOwpScUn83p0SdZo6XmM+6oaG/CbKCcbohzbTg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786867293; c=relaxed/simple;
	bh=lpo4I0txAlV3EWqxLW3j0hiSsXefJAiYqgAbCg2N2gQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=IamlE7qzaewC8ONoyuwGA68ZFouB4SFv54KyVUgGTVzTxERzTus9gy4wWRPmvH7cfZvA8kgdmRW/1kkTmWdaaE5t5fDz6jzmeF1uX0IaGYNsP8ytVMjqHCHOfwfhZy2NY5nIH6PFoJAD10rcLKoUclNxd0TW+H9ZekYoKHBHv0g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NYuZJj5w; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NYuZJj5w"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 7136BC2BCC7;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1786867293;
	bh=lpo4I0txAlV3EWqxLW3j0hiSsXefJAiYqgAbCg2N2gQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=NYuZJj5wwzhJGg+wTgACotem3IGWCrb11xVyZvmRFo/ndyj4zAu0yceO2xpTy/asm
	 2f/ePcOktySEkLNRfXn9NsNgF9R1UV5r24WqePEeWIIwaoKEautv1u396uhwuaz/Cy
	 DzjgoLHERtBrqARBkGq21/ZFtT3JF3bi1roMyRyod5oPmyW4vVqSlBzctht04zHDmn
	 n4rrq/jDWlQ8LvgP7AWhelzdcEJNhwFJqwNUaTXWDexiXwrvaogFf+/0+zxlz0mtXO
	 pn+2jkm3gO9Eb7Z5bYbAo0cGojCFNXFp+709CARs9p4e3rHcxWS4eNJ6J9sJ9Ux6Ef
	 R+y/caO/0nTvw==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52642C5DF6D;
	Sun, 16 Aug 2026 08:01:33 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Sun, 16 Aug 2026 16:01:27 +0800
Subject: [PATCH 1/3] NFSv4.2: fix LAYOUTSTATS send buffer exhaustion
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260816-nfs4-fixes-v1-1-a810f21729ab@outlook.com>
References: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
In-Reply-To: <20260816-nfs4-fixes-v1-0-a810f21729ab@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Peng Tao <tao.peng@primarydata.com>, 
 Jeff Layton <jeff.layton@primarydata.com>, 
 Tao Peng <bergwolf@primarydata.com>, 
 Weston Andros Adamson <dros@primarydata.com>, 
 Tom Haynes <loghyr@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Trond Myklebust <trond.myklebust@hammerspace.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1940;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=4WLBba8p7bwGAneqhTqmcyaXp3xOnrgg5APLE5Akwfw=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMa8aObCHElOMalOsUVr5u+QsLd4nMyhIbP2U+Py5
 HpGx23vvnWUsjCIcTHIiimyHC+49M3Cd4vuFp8tyTBzWJlAhjBwcQrAROrOMDI8jQl5MC0yeea8
 nCvKP36oM3qn7Z0fX7guZU/wJdFC63nmjAx/mjvautqNKhb8WXr/t8L+1y0TlslUcy6aYTlVuGF
 +qSofACusSMo=
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

encode_layoutstats_maxsz budgets XDR_QUADLEN(PNFS_LAYOUTSTATS_MAXSIZE),
i.e. 256 bytes, for the layoutupdate4 body written by the layout driver.
The flexfiles record can exceed that.

ff_layout_encode_ff_layoutupdate() emits, per data server, a netaddr4,
an nfs_fh4, two ff_io_latency4, an nfstime4 and a bool.  A data server
whose filehandle is NFS_MAXFHSIZE bytes long already accounts for 132 of
those bytes, and the two ff_io_latency4 at 64 bytes each, the nfstime4
and the bool add a further 144, so the body passes 256 bytes before the
netaddr4 is encoded at all.  encode_layoutstats() additionally writes
the deviceid4 and the layoutupdate4 lou_type word, neither of which the
macro accounts for.

The filehandle and the address are both chosen by the server, through
LAYOUTGET and GETDEVICEINFO, so it can drive the encoder past the
end of the send buffer.  xdr_reserve_space() returns NULL once that
happens, and the two ff_layout_encode_io_latency() calls run with
dss_info->mirror->lock held, so a NULL return there leaves the lock
permanently held.

Raise PNFS_LAYOUTSTATS_MAXSIZE to 384 so that the record fits inside the
reservation.

Fixes: 27c430644369 ("pnfs/flexfiles: encode LAYOUTSTATS flexfiles specific data")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 include/linux/nfs_xdr.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 11c5b31cfc7d..e8144048cd0e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -354,7 +354,7 @@ struct nfs4_layoutreturn {
 	struct nfs4_xdr_opaque_data ld_private;
 };
 
-#define PNFS_LAYOUTSTATS_MAXSIZE 256
+#define PNFS_LAYOUTSTATS_MAXSIZE 384
 
 struct nfs42_layoutstat_args;
 struct nfs42_layoutstat_devinfo;

-- 
2.51.2


