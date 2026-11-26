Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=148.163.135.74
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795659929;
	b=gh57nrH6zmWalwTDyZcWSgub/3uzDTOXGOdBx8bldOWo5CJFMESq0NpmCi/ikTPq8frK
	 13hCWKWpv7Bkt3HPYMbXieZUMrHuAtMaGiiByjrNaG2r0QV2hV3zeozDzUak2VBgJBdln
	 7y7/NNMIZxjhwCjiTcflRUR1ygr2WWny7DhCqQjwkZeULuMgYjX61pxOQ5fkBc7E6DNYz
	 4wF+A5x5Z+SbkyjhTyobM1EUAJZcv89OfefVczeo1MTn0GS1guxR1lqnS23hqWXcu/Wby
	 b7+FHRLzVlSQrWTFieM+pAWvO2cBi+XC5rDUSg+ADoUjie9+RIFJFDiLsW58NQt1o9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795659929;
	h=DMARC-Filter:Received:DKIM-Signature:Received:Received:
	 DKIM-Signature:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:X-Received:Received:From:To:Cc:
	 Subject:Date:Message-Id:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-Authority-Analysis:
	 X-Proofpoint-Spam-Details-Enc:X-Proofpoint-ORIG-GUID:
	 X-Proofpoint-GUID:X-Proofpoint-Spam-Info:X-Proofpoint-Virus-Version:
	 X-Proofpoint-Spam-Details;
	bh=bq5K8Z87IavuvaaKNiqMth7LGJ8zdX5mtp1Bwcp67Uc=;
	b=1MJTuEfKedCIFn/p+HPQWaPrIvYOZNm5rQAYPK/FLhprpP0UrO/I/0M52TMvHVaq6ym8
	 8cuWLRQon5yyn3mvqqRhnNueME/E1fqcNA/IhJ4uTeax8WrrJ+ij0xN0ywHYJ8VOaVN6A
	 wlDRT5H91t7GtNJ2E9vsauRQEw7HEEm6+Gsb2OtJ9QcZD/5dTFkV9Y9baApjs5sayZj/Z
	 16rWOYAVdd0j1FZhTkCIOpn1tTwR4zcWAIJFrn1J4NIXehEHmfH+gmSHOEJOa+/sxZ3cU
	 ru+00xgONo/KDTVIsSBbq18bq78GRNQzcfI84mT67Er75ew1F6jO9gFWWq6GuA1cG1w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=columbia.edu;
	spf=pass smtp.mailfrom=columbia.edu;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=azAUGPgc;
	dkim=pass header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=Ki+KHe6M;
	arc=none smtp.remote-ip=148.163.135.74
Received: from mx0a-00364e01.pphosted.com (mx0a-00364e01.pphosted.com [148.163.135.74])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A76F606A32C
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 02:25:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8A76F606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=columbia.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=columbia.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=pps01 header.b=azAUGPgc;
	dkim=pass (2048-bit key) header.d=columbia.edu header.i=@columbia.edu header.a=rsa-sha256 header.s=lionmail header.b=Ki+KHe6M
Received: from pps.filterd (m0167070.ppops.net [127.0.0.1])
	by mx0a-00364e01.pphosted.com (8.18.1.11/8.18.1.11) with ESMTP id 6AQ2HUfk1883501
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 21:25:22 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=columbia.edu; h=
	cc:content-transfer-encoding:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to; s=pps01; bh=bq5K
	8Z87IavuvaaKNiqMth7LGJ8zdX5mtp1Bwcp67Uc=; b=azAUGPgcRU1jSI5UcEdk
	lX/Oam7hV0qSGuaoRoZ76iTO+yUv1p2TSRxSWqw/GV116U6mifykV1LTK1RDVF4I
	iKOPSY3PSz8vfny7Ha9obUkbMW6zmIsYItSxjLycctsWrDJ2rP2Qa4yaT+QQ9KqU
	+4dz298p9gibceQ5lCgFjd5gQzpe1qreD1yq7bVWWajVHsF3DL8u2w+MyeG6JCax
	6uARcxrpY97cBRd9pD/9MBjtHydvImyxeSEwdpM3USUiXBCQARMKKoJ4GgI1FvmR
	xUwASOZFEFsMGQAO+s7arILwa8QlmuqSFhjk/ZCiUMSZ1ZhwWwfuQrgDVwgAtLqi
	3w==
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by mx0a-00364e01.pphosted.com (PPS) with ESMTPS id 4j68hh1193-1
	(version=TLSv1.3 cipher=TLS_AES_128_GCM_SHA256 bits=128 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 21:25:22 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-93f5844e383so983151985a.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 18:25:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=columbia.edu; s=lionmail; t=1795659921; x=1796264721; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=bq5K8Z87IavuvaaKNiqMth7LGJ8zdX5mtp1Bwcp67Uc=;
        b=Ki+KHe6MDEgfProqRIGk0un22f7ITJdGDVR8RFLPbBwg0ny1Bmym8YPhpeZ5n8UlJd
         uG7LtT0XBxXgDmmNj5VuE8pkpIlTsmrOYMww30ypNhH3jQGBmDe/EyrlIGJ7jfYGlEL4
         7qYCGuERLyRh2UNAj2kvUeVApVok7C9JRl8404UQg3FXcsPs+CyLH4KFqOWFLRL3Ll7q
         ARh/AYUGKeJJuaXrpWt34OkALRiyTeYrlsd84E/N4Fe1r6aiLKwda5YULwMZWtlFQtI/
         bCN5U4LkQ4Tf7erCDpoVEO1+B3yiqWYQ7ntypEgKTJuWN2IyZs1VtR/yv8W48b1FM+wm
         eTqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795659921; x=1796264721;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=bq5K8Z87IavuvaaKNiqMth7LGJ8zdX5mtp1Bwcp67Uc=;
        b=QzE+u8zaXvLIgxfd0qrrr5PfOdNVX4Pgi932R86cuCE2LAGXcz6edRilb9sKgQqAqy
         W4N2UAhsNKrTdQtPxWedTadxxgAE97GOIBK3lc06xgdKDmNKKN+9vsEECKF/GFIVYWiu
         56QqGbAn525zj16cpwJ1ypE+BpDN4NAuwshINirUEDROCE3a210ECeJXRp4/WZfDIHcW
         Oeyxjb14POvlQHQ0q7UyNIFOVtM4UmfeKLTXST1j88uqzlY/Hfmoo8DrqvfHZIugAgm1
         uV7csb/6vqhqyBAmH9TuF6wwdtfoAN/uDkNdoge82HYm+kkSdbKErygfPQ89RjynPFZl
         5QwQ==
X-Forwarded-Encrypted: i=1; AL+hErF8tiis9/f2P4w7cZahi4aVGPjStNet6MIxkUh9j+0oEQMt/wbdV1Bb3i0+Zi3nO2G6Th48UptoUa8=@vger.kernel.org
X-Gm-Message-State: APuU4Z8rGm6tbUZyw1rirYltRb97up10MAb8WggqC6O8I5C2wFtIyDUU
	hoRODGIyKS6x8NR4pm2b14ST9Q4vqQS4CbkDIt6N14GcbegILRFxAHcRSFNOt6XaBupZC0f4cOv
	I4gvWonxWQ7FNbuvLqj/z4cX6y2YEZPnRfk4rjbrlMBviFUrOEWMaQB3NsA==
X-Gm-Gg: AZFdTZdgj8KNi/4ltlYrO65+mBlLmzDaZgbQj+kpgJ/cFCTq5KgfoxxGaN8MWv9jI3D
	+xh+RQO6BosPH6iQj/S6bHx61j+q3kiRTjtF3rOEU9oWq6ltflIj+ZEZdTiMbRCMGJVYeiW4upb
	+vXu/AwBENXeqrkKYgpeigR0MPen6FZnVLT0I32PGwHr2Z5dEtgRmkyRWv49p2Sh3q0rugx+JLE
	nNQRphsIg4Kh+oc0o4LOAGpAtWHBg4UZMFzqq5dNrZidjFKhLdrUB4grDk9UpBJGzV8+Mm3TfUC
	r6PTd77HCPFxzvG9fJ82txoWkDqy84VrB2GI0MiLbQfWxI0Vnd7lDlFGzq0/DfIF5Bt//egtWZh
	LuBVgY8UbITgMuC6zoNWXfeCZA6IAcHu3CsXQSYpvgwLYjcnZBxPbwWmuzy4CQS504ySHi+tC3t
	5kvzfwop4cNnlLbU9q9JFwcqLclqTR43s=
X-Received: by 2002:a05:620a:1b8c:b0:949:7920:9d09 with SMTP id af79cd13be357-949ba99fdd3mr3499404285a.35.1795659921396;
        Wed, 25 Nov 2026 18:25:21 -0800 (PST)
X-Received: by 2002:a05:620a:1b8c:b0:949:7920:9d09 with SMTP id af79cd13be357-949ba99fdd3mr3499401185a.35.1795659920987;
        Wed, 25 Nov 2026 18:25:20 -0800 (PST)
Received: from localhost.localdomain (dyn-160-39-33-242.dyn.columbia.edu. [160.39.33.242])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-949bb34ae74sm1452063385a.8.2026.11.25.18.25.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 18:25:20 -0800 (PST)
From: Tal Zussman <tz2294@columbia.edu>
To: "David Hildenbrand (Arm)" <david@kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.linux.dev,
        Pedro Falcato <pfalcato@suse.de>, John Hubbard <jhubbard@nvidia.com>,
        Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>,
        Zi Yan <ziy@nvidia.com>,
        "Matthew Wilcox (Oracle)" <willy@infradead.org>,
        Lorenzo Stoakes <ljs@kernel.org>, Peter Xu <peterx@redhat.com>,
        Johannes Weiner <hannes@cmpxchg.org>, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Liam R. Howlett" <liam@infradead.org>,
        Vlastimil Babka <vbabka@kernel.org>, Mike Rapoport <rppt@kernel.org>,
        Suren Baghdasaryan <surenb@google.com>, Michal Hocko <mhocko@suse.com>,
        Baolin Wang <baolin.wang@linux.alibaba.com>,
        Nico Pache <nico.pache@linux.dev>, Ryan Roberts <ryan.roberts@arm.com>,
        Dev Jain <dev.jain@arm.com>, Barry Song <baohua@kernel.org>,
        Lance Yang <lance.yang@linux.dev>, Usama Arif <usama.arif@linux.dev>,
        Kiryl Shutsemau <kas@kernel.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Kairui Song <kasong@tencent.com>,
        Qi Zheng <qi.zheng@linux.dev>, Shakeel Butt <shakeel.butt@linux.dev>,
        Axel Rasmussen <axelrasmussen@google.com>,
        Yuanchu Xie <yuanchu@google.com>, Wei Xu <weixugc@google.com>,
        Baoquan He <baoquan.he@linux.dev>, Michal Hocko <mhocko@kernel.org>,
        linux-fsdevel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH RFC 0/5] mm: GUP dirty + ->release_folio() fixes
Date: Wed, 25 Nov 2026 21:24:18 -0500
Message-Id: <20261126022418.3620783-1-tz2294@columbia.edu>
X-Mailer: git-send-email 2.39.5
In-Reply-To: <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
References: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de> <4f096d70-6f94-4148-8f47-242b8551e5f9@nvidia.com> <awWNyDZT2SVu2Zp9@pedro-suse.tail5790ac.ts.net> <55114986-0ba1-4a80-8498-bf674d64e01b@kernel.org> <away88BuU8ibcTA5@infradead.org> <d088452f-1118-4a06-bc16-1942e523e0fc@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Authority-Analysis: v=2.4 cv=fuRJ914f c=1 sm=1 tr=0 ts=6b079892 cx=c_pps
 a=hnmNkyzTK/kJ09Xio7VxxA==:117 a=GaPK54s0Se3oFqK5NkZy0g==:17
 a=IkcTkHD0fZMA:10 a=zJRp6_cAMcgA:10 a=x7bEGLp0ZPQA:10 a=A0y_DWxS2BwA:10
 a=VkNPw1HP01LnGYTKEx00:22 a=Da8U98TiO7q1upZEImrf:22 a=svvvyxlR1OQQkelhaPoB:22
 a=VwQbUJbxAAAA:8 a=X-ZpGw2H3ZcMOUJhEmsA:9 a=QEXdDO2ut3YA:10
 a=PEH46H7Ffwr30OY-TuGO:22
X-Proofpoint-Spam-Details-Enc: AW1haW4tMjYxMTI2MDAwOCBTYWx0ZWRfXxg7ohcLXnvKw
 mvLcX3qd/65vt7QHtYpIe87vDXqefxVBTAWOQROdQr8bxXEdAvwXvTP4nTdnQoZMlPC1m+p0Tki
 0ivdtcSsZO4bv9cm0Dzbubu32xMeIqbHjd04XUgbhrUqyhXrYOj/mtzEgoloOhnqzz+WxxcjsL1
 vD2+knYBd/GQt9sYYBE+f44j/SZiqzHfCsqgrJgn2ZJiEriiuXDV7DtswvfeUcepE2Ob2npS5bT
 /GfDdujW2SLNeCFvlKgubRTmarZ+/wF8zhZ+/nHdiP2h4wE38+i+ru3DQGrQu6ra22gyNrQgz6u
 jIUzYE2h1e61hxPqJxyJ8vpFREsp7Spd1cHfqY/HDvGDLBBT5OjC7U1QM21XpEFwxZ7oBEj0SBa
 4wJWeEYS/t3ShFTqKrnMYqYovD1DpsnRyLu13vX3LeJyO5bdLSdRQE2Vs5pWlPhFpswo5wwshRl
 2mFDDSwFHeCh0usI2Dg==
X-Proofpoint-ORIG-GUID: cvby04fjIf3CSRN3M1PHjs12UJSBPETT
X-Proofpoint-GUID: cvby04fjIf3CSRN3M1PHjs12UJSBPETT
X-Proofpoint-Spam-Info: AW1haW4tMjYxMTI2MDAwOCBTYWx0ZWRfX65jYvB7abxZP
 5aroWTKAWgYmBbYkLEXLPW6QONEcrYZoEk51OZ8vZkYdQtBWsrxgIzs+kgY8xgoTqDfjebapL2k
 hdxS2RGxr42rOb+3rnSd03W1e7ig/hMEG3hhIR08oqhTJ8HhjpHE
X-Proofpoint-Virus-Version: vendor=nai engine=6900 definitions=11977
 signatures=596817
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0
 phishscore=0 lowpriorityscore=10 suspectscore=0 bulkscore=10 malwarescore=0
 impostorscore=10 adultscore=0 spamscore=0 clxscore=1011 priorityscore=1501
 classifier=typeunknown authscore=0 authtc= authcc= route=outbound adjust=0
 reason=mlx scancount=1 engine=8.22.0-2611040001 definitions=main-2611260008

+CC Miklos

On 11/25/26 5:19 AM, David Hildenbrand (Arm) wrote:
> On 11/25/26 11:05, Christoph Hellwig wrote:
>> On Wed, Nov 25, 2026 at 10:50:42AM +0100, David Hildenbrand (Arm) wrote:
>>> 1) We fix all such cases now where unprivileged users can trigger this,
>>>    converting to FOLL_PIN.
>>
>> We need to, if not for this series then for all the other outstanding
>> issues with GUP writes.
>
> Cool, and I agree (that's why I placed it at 1).
>
> But who is "we"? Because I recall that "we" wanted to do that a while ago.
>
> (I won't be "we" ;) Pedro, can you take a look? I'm afraid the fuse thing might
> be the harder nut to crack)

Coincidentally, I sent out a patch to convert fuse_copy_fill() to use
iov_iter_extract_pages() a few days ago in order to remove its usage of
set_page_dirty_lock() and address a different race. I think it should
address the fuse side of this issue as well.

https://lore.kernel.org/all/20261120-fuse-copy-fill-pin-v1-1-72a0d888f140@columbia.edu/

Thanks,
Tal
