Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25514244687;
	Wed, 23 Sep 2026 14:11:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790172665; cv=none; b=H713jGLhgs3mESOL9O2GbdwcPz2SEIwQKHOSvq3zaRn+acpwX4QGTSr4siqlrHd5qUv3F9Wtdcl/+l1cRSof3OLgDl/roQGg3YWXkfD4mkPz2b77BI+KbaKz/wsv5JDBs2pXSt+NM8LacHyHywjPv/Zf9Z4av1gcZSoL0tw1Bms=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790172665; c=relaxed/simple;
	bh=UweFKwytZZxYIDDoNfjYqv3WfPufbk7GnnBDZrAIlbU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:Subject:Content-Type; b=ie10T35IuFYXv/QjmiGWuox5Vd6FUigZ3rM7YVJn7DA7Omtznaxupo7UmjsE+VbPEJwGXTvjyZbglP5kogw14SmzbFZ8nEGW7J1qoV0i5O/+XJtJpu6D2cyLAR/Ab8I9j07zr80efEz1zScjS4AkA34D5Ja++Lrip6VMg8Roo4E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T2crP8ZV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T2crP8ZV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BAB451F00893;
	Wed, 23 Sep 2026 14:11:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790172663;
	bh=Li+z3luhpebsISbklx2gY0FprM1+elRGcyqmF+pdx5I=;
	h=Date:From:To:Cc:Subject;
	b=T2crP8ZVLxlVlBBvbtRRMX2XsP5W4fP+N9zMWtOVvkNGs4iqfIwQh7NgIZA34l3Ut
	 NvkO0T0ecbx8oNrmxKNUwGzme64iC4ha79bugyCCYi7UcqN1nq6ALrU1XvrQ9wO5fk
	 dTIj1FAfw7rKtL31xGbth+k/VK6cWnkxv3kWB4p2CfxR8vYzOHlzLZivWUJBZpk2Ef
	 Ewi2cWtOrguPNPVnqOJSJcifFoPk6fufpmE7ZmqAUZv9EDw/tro2T9Cu8rHiYi+xa+
	 h5hRwm4362OXJ8/AdkjR4KlHlw1X7amR8TWcX0g0FMMkci2dMq1y6DtGLHZ/ptGe1N
	 zWRL62LuGodeg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id AAACFF40066;
	Wed, 23 Sep 2026 10:11:02 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 23 Sep 2026 10:11:02 -0400
X-ME-Sender: <xms:9t2zaqIbad-KuGLOuCGMOIGMaBzxLO5mXpwrx_y9tdflJWgz2i04hA>
    <xme:9t2zas8je19ebbvDyxQgtbljdcVOGKQdJpUBBdnOiOZBALNFyQUvSrj9QI56LgRsY
    OGJwhwB3or6CqZ7ogMxQMm1KES_IgwMzuv-R6JS3AXP3PDuT8SzerbS>
X-ME-Proxy-Cause: dmFkZTGAuDRVOdY94hnFTsU7RLRxBH44odXl49kKuep+65Fnns6Y3OBUZE7qZWwcEFPuJ+
    XnRj04ITJxU5G7H/kaIA7/5CUlaxCVMO92H8XNPLlaqeLOSTTJCpwFNZXMsQxGvaQRUmp/
    4nE8huqUNxo571v5hNoD0eNiIdsPa55bI23WxcurUHe8XjjQHyxMIKXLhzsh/RX6BJEJRf
    AxG5PpuB6xU8hqHZDK+5PLRfQrzXhDcbcerwThVGvpm48fccw3RMfMawBZKLibp4COUGYA
    E6GK4sWgIdO+nBFCi23R2a/oVBLR7JhGVNdQhHf/zOGmFcmBz1PtW1QSkP/7xvBPoBS1Gv
    9KlBIOImn2ietZnVI1YFtWFYcok7sS758kO4+eBYTTImS+aKQH4qYi75StTlfXN+jBT7Uq
    g/GHMztt4lBG/u2nhY0PBDSUmkef6Oq84auUzj+tVK58IyMFdhgZ5Nwoo4kOKHen85HsVt
    HllwXsDgakGMIpD4ou4u4KeZuEwO4SXF4SioXaPU13tyBp9AxGWnt3FY7LY4wt4Qgg0Im7
    fDOyTxPdIeMhhqZCwhLB5r95A8Oj18X6+G420AbMkx2cpytj9AYMlzvcyzZFsP/LQ9UGsC
    k1l+aJ21v6UOKX1yMEG/Nv/b10pCvG1R0UUInYjDBGDcflybOKvyaXL6Kr6w
X-ME-Proxy: <xmx:9t2zaiv2R-gjNtTqpGMavWRxGbFUgM8_Xpgfht2rn1haXo6Awz60iQ>
    <xmx:9t2zaucyoSqa37_6k1FW6JKR2BA5zMInBNFB3LAoN9t2FAjATD9TNw>
    <xmx:9t2zaixEPKfbt7tNY8SNUalIR7q8-E1mJIKF5noB_UR8boORxpoBjw>
    <xmx:9t2zasGcmDMwfNJC4Er49t93ETOByZ4valEgNQ1Jmdq8pgoVs1vmHg>
    <xmx:9t2zauxZ_aE8tFVSFab9nNnX-pNQxIFY_tIAHgqlBzFGax6b9iQZ8S5F>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 9169A780070; Wed, 23 Sep 2026 10:11:02 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Wed, 23 Sep 2026 10:10:32 -0400
From: "Chuck Lever" <cel@kernel.org>
To: kernel-tls-handshake@lists.linux.dev
Cc: linux-nfs@vger.kernel.org, linux-nvme@lists.infradead.org
Message-Id: <56c0423c-bba9-460a-871f-c22fc2d5af23@app.fastmail.com>
Subject: [ANNOUNCE] ktls-utils 1.5.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

[ Although the email displayed in Thunderbird as a plaintext, it
  was sent in HTML format from chuck.lever@oracle.com. Resending
  as 100% plaintext with my apologies. ]

This email announces the official release of ktls-utils 1.5.0.

ktls-utils 1.5.0 adds DANE authentication of server certificates: tlshd can now
validate a server's certificate against TLSA records published in DNS, with the
new behavior governed by DANE configuration options documented in the tlshd.conf
man page. A new nfstlskey tool manages the NFS client's mTLS identities, and
tlshd now links the NFS keyrings per handshake rather than once at startup, so
identities added after the daemon starts are picked up. Private keys may now be
named by GnuTLS URL, which enables keys held in PKCS#11 tokens and TPMs. The
post-quantum ECDHE + ML-KEM hybrid key exchange groups are enabled. Kernel
capability detection now reads the handshake netlink policy, so new kernel
features are recognized without a tlshd update.


Official source code repo:

https://github.com/oracle/ktls-utils/


Release tag:

ktls-utils-1.5.0


Release artifacts:

A source tarball created automatically by GitHub:

https://github.com/oracle/ktls-utils/archive/refs/tags/ktls-utils-1.5.0.tar.gz

A source tarball created with "make dist":

https://github.com/oracle/ktls-utils/releases/download/ktls-utils-1.5.0/ktls-utils-1.5.0.tar.gz


Issues and requests for enhancement:

https://github.com/oracle/ktls-utils/issues

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
