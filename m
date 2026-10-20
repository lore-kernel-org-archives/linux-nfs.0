Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792514301;
	b=qcKU3kL15heTvk2ls+CSRAHv3rmsjPRcaZOuLII3tADO7KYYaMaMjHgMAIXTTRJ1PYwn
	 XnyFstUgjcwcS65NkEuQoWNQHNtHL9GzFk2BD4/KkUDAFB9mD8Mh9RGx0tCUFGeBLm0Yx
	 sGFiG1H/W3T+ZPOKPHlFjXOCpZCMlWSAPcevlSMqrQX92aIlYgooOwxKMYOupOHc7AJ6K
	 wXl65Pg05v+aUfGmGJWXBeVOKpAADARuTJw6AoiJj1TTeb5p1eFkkKqNdQ9PyX44SX7oA
	 aKRFsXGBTCL9iHBXS2gDlTFslY9JcXAwcKW4Du8ysir9aLOQu4uj5jQpg6RVGQ8zhLg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792514301;
	h=Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=QAth75X1EAvTGDV42tUcmeCns5v5P5BRoXB5oGaiwiY=;
	b=uZpEf4fN2W2rH4h014uIRNn9pMreg+qa7shHMDtWhD26Dxkz8u/ck3iO/e9q3DglMaax
	 HGh+sHRrLBlZgM0+6Uqw5u3KPMbeGhU3IKrckHJk9E7RaOSpuCmGcpI3yauwSHYTQJ0Qz
	 lC3hZw2oHAzYsmgXijmOn6+8s5sLXEk+w6XyHdRr3MS4lUxPSpIdN1PX0pPER68hbBTI6
	 0FggD0edqXXt28H4CjgJKjohNUT3EgcmOzmu0iLPnMh3aLIExZZ3wleN8BrZtCmdnxOq4
	 o8iI1Zv0fjS6ujVIgXHLbYzujotoONQgGqPjoZmEjY2QdGZ7yPmI/2w8O+w13/0yGeg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 489B1606A32A
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 16:38:21 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99C2C1F000C4;
	Tue, 20 Oct 2026 16:38:20 +0000 (UTC)
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 0/3] NFS: Modernize decoding uint32 arrays
Date: Tue, 20 Oct 2026 12:37:46 -0400
Message-ID: <20261020163749.262930-1-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

We've had several reports over the last few months people have tried to
add bounds checking to the various places that need to decode a uint32
array. None of them update the callsites to use
xdr_stream_decode_uint32_array(), which has all the proper bounds
checking already implemented. These patches make that change.

Changed in v2:
 - Properly handle -EMSGSIZE in decode_bitmap()

Thoughts?
Anna

Anna Schumaker (3):
  NFS: Have decode_pnfs_layout_types() use XDR's decode_uint32_array()
  NFS: Modernize the callback decode_bitmap() function
  NFS: Modernize decode_getdevinfo() bitmap decoding

 fs/nfs/callback_xdr.c | 26 +++++++-------------
 fs/nfs/nfs4xdr.c      | 55 +++++++++----------------------------------
 2 files changed, 20 insertions(+), 61 deletions(-)

-- 
2.56.0

