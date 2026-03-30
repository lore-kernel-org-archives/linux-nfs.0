Received: from hr2.samba.org (hr2.samba.org [144.76.82.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D023D3A6EF7;
	Mon, 30 Mar 2026 13:57:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=144.76.82.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774879073; cv=none; b=KS4yGh/ex8ephWK/UeLIewPIeiATS2bY+MJ6I/zw3bmyhyt5xH5TkJLmhtmUhl3kM+yUtEw9JnuLkkScYndN87t2F6FZRQ1yWU3V04pDUQagVLorpR66rJPbdJK0sA1RgLjjLPdStMLpOeJ/B10pmbDLrY8QqZfwSXpB/n0mWZg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774879073; c=relaxed/simple;
	bh=pcW6LXETd4GRRYCmR8ynpqdeQSEEzpJd8b7cdKVtty8=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=SY0C3MfwyOtCEQPiI7597X2J+jA/BfqU/vc6Ahmr0riSzFqEHDW4ngmGgga9nLCCXeakwcNEmwqaeFOveIQjWfpaLGj66OBee/hub5i3If7Jbw7e0ZfStQx8c3j5jMjLEjgmW90zVz9St13YjznVs/HCOlbWvSZ0CAcFYyegcvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=samba.org; spf=pass smtp.mailfrom=samba.org; dkim=pass (3072-bit key) header.d=samba.org header.i=@samba.org header.b=lSYNp7Wf; arc=none smtp.client-ip=144.76.82.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=samba.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=samba.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (3072-bit key) header.d=samba.org header.i=@samba.org header.b="lSYNp7Wf"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=samba.org;
	s=42; h=From:Cc:To:Date:Message-ID;
	bh=aHLXtwCMFeKjEs/VsnRh986+QoltAhaGyi5eb+m+M2o=; b=lSYNp7WftXgNZI9nAPuFMFcKqY
	HEmA505012e9xqEKFQaNN1zovmIMMfDhNZY37xSKz2H2whDuvOmUZFmRxWz3Yaqnl/BelRXXp44rw
	Y37GF+vBFdN1uNuw5CZTbr66zdDM08ln+E5ImeL4BcoAfP9R9v1BIE9GZHzP9ZWEWNuFwee+HjifT
	Xpye22zs124AMG/L1f2BAIylpljBlz0jNngKSbDfSWKnSx4pR7WEfoAfIANLq+RGWwpoqALSvK5wq
	QwAGdLAO0tdCgSWWQw5JXUdt7q4bCG8mpUq4nc5S1VfADIFpRkXiOCjGf6UJ/FNmqyfheFdUVwZu4
	9mmWLziXMCsHMnERmzv106kqFnT+hqVLPuW/f84tnZfNDxT/oB25+Pw3ASTxShUG260kt9palsKsg
	TN/W2lMJA++aKUig0vH7n6qlghHLahYcjmUvDxhrAIl/0/94Y9U77HhO+CgFinlTv1xR/drRKxmik
	sB9oukHjqX3Ywk7rgEeGLZEC;
Received: from [127.0.0.2] (localhost [127.0.0.1])
	by hr2.samba.org with esmtpsa (TLS1.3:ECDHE_SECP256R1__ECDSA_SECP256R1_SHA256__CHACHA20_POLY1305:256)
	(Exim)
	id 1w7D7b-000000055qd-0zuk;
	Mon, 30 Mar 2026 13:57:39 +0000
Message-ID: <9639cd12-5e9d-4eb4-9d9c-f5047ccad7b7@samba.org>
Date: Mon, 30 Mar 2026 15:57:38 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 00/26] netfs: Keep track of folios in a segmented
 bio_vec[] chain
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
 Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@infradead.org>,
 Steve French <smfrench@gmail.com>, Namjae Jeon <linkinjeon@kernel.org>,
 Paulo Alcantara <pc@manguebit.com>, Jens Axboe <axboe@kernel.dk>,
 Leon Romanovsky <leon@kernel.org>, Steve French <sfrench@samba.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
 Marc Dionne <marc.dionne@auristor.com>,
 Eric Van Hensbergen <ericvh@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>,
 Ilya Dryomov <idryomov@gmail.com>, Trond Myklebust <trondmy@kernel.org>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-erofs@lists.ozlabs.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <52ad0aa6-d8dd-4ba1-adf2-f79128df9d90@samba.org>
 <20260326104544.509518-1-dhowells@redhat.com>
 <1180465.1774867781@warthog.procyon.org.uk>
Content-Language: en-US
From: Stefan Metzmacher <metze@samba.org>
In-Reply-To: <1180465.1774867781@warthog.procyon.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Am 30.03.26 um 12:49 schrieb David Howells:
> Stefan Metzmacher <metze@samba.org> wrote:
> 
>> Another possible way would be to skip this for now
>> cifs: Remove support for ITER_KVEC/BVEC/FOLIOQ from smb_extract_iter_to_rdma()
>> and I rebase my changes on top of Davids patches assuming they
>> will be stable commits (at least up to
>> cifs: Support ITER_BVECQ in smb_extract_iter_to_rdma())
> 
> I could certainly split my removal patch.  I want to remove FOLIOQ support,
> but I can leave KVEC and/or BVEC if they're still needed.

Yes, please keep them, I guess we can removed unused stuff at the end of the
merge window.

Any idea on how to resolve the actual conflict?

Thanks!
metze

