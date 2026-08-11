Received: from flow-a2-smtp.messagingengine.com (flow-a2-smtp.messagingengine.com [103.168.172.137])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF1451C860C;
	Tue, 11 Aug 2026 04:52:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.137
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786423942; cv=none; b=kZ85nPMDQnr+DXjKsJ9UM3syfGpK7PUPd5FVHn0KFC3jrUktmOImNtrsMsMy+FF96bDMwhVjLHyreT/h9kqfkyMcwOOeBV6NroYYf0Yddbdk6OL2V7C2wfcCPFODrMMp2yGMwQALi8f6nDTwS/DbeW9g8TdMv0RoaOH8Nt2Sup0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786423942; c=relaxed/simple;
	bh=X/2QnnsktF4WXKr/vX4FVIwRKMveAg0TaT0OXQxA/rA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=cB03fgDfuL8lq5TsWt4unEh6e2vhR7VJjuQu4wto2QWRnuW1y/cpB8+wmJ9wyPaHJMwSDEb+Z8rZEOo0g+A4s/O70LIMjMczo2PxEb9GnK5LdmkLJScn3FIdX8Dg7sAjBJ2m7TINV0ldQu/mRHvSjRJ/pTw98Rj5Fh/7Y4y1kQ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Lz9+VXLU; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=SOx3JixF; arc=none smtp.client-ip=103.168.172.137
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Lz9+VXLU";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="SOx3JixF"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailflow.phl.internal (Postfix) with ESMTP id C524B1380013;
	Tue, 11 Aug 2026 00:52:18 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-09.internal (MEProxy); Tue, 11 Aug 2026 00:52:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1786423938; x=1786431138; bh=ekTBr3doJmrrAeJj4ehw8/L9FJAkO0UqerH
	r2gMD4JY=; b=Lz9+VXLU44VgkUNkfXkF8BBsrluBO7OWZQpFxfIHRjBShF/bQYL
	a889Qimvz5on00P59tfvjhCAD+9XFMdKSBd6vpI/V8JKmk7I3CdHYrVkFxOlQyHS
	ASptwydJRufLHSW2zL62Q9HKTG4uKhWzMwI6b3CJ4cWS0DfeYrFL8betFGf9lZ6D
	VyCa8DOSLuwbcV5FN1MTpnnBeY/3UZ3Wym9OK2cFaaiZnOW1JVmQQzvbIyhcgTgR
	AMT97okADeXl/Vw0v1AcnKSYlgEPAlKlP3iBqGnWh5aYGi51f1qi3MniW3egUXwH
	h/hXNP7LogH8PZlLqqFKwj6i1DnSoiBjVZA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1786423938; x=
	1786431138; bh=ekTBr3doJmrrAeJj4ehw8/L9FJAkO0UqerHr2gMD4JY=; b=S
	Ox3JixFn9rwHIl2mjSRy+zFJhYZZdblV+lW6MIRuHh1UNBZxL7FqvXZxnNpmdFXU
	uYaiN3gPV0adt7P37zQgazkd+6icaaGuKz/O2EYauJ125QufCoXjtabO41RLVctc
	l6WF9keqDksCXZoosx0rO6Te0xj4jM9XydbsAO7SZzjChptE8utBhAsnqrdYMvcB
	GavDlgbDjfpsVquSYiKtm3Dai4NutwLWjyH6QNm5VGvndNuyV45lg1QJA7oGIfEL
	C/Fez7tOfaVgU4zqmruP7N6EQonKwPnixlYRbyMhhX/lTlVGdYRaPs324r+7g6i2
	2tApu6mokwcfOrn04xrzA==
X-ME-Sender: <xms:gap6ah6fkGyzTcu4ufMufQMgYaJcL77sjevaboRp_0QVJ03Rl-5cwg>
    <xme:gap6aglPjW_PPkYvJJgqLIiL17CaZu_z7SUXvzS0YzpTYNRDK-zpOYThU-BED4JCb
    KHgx8GMbJDgs7P_P8YwiyLaTZwIlzFq6X2Gb0jj0agw44o>
X-ME-Received: <xmr:gap6ar5tdxu7oF9MoV8qpsQJQXk6dUEo6Vo1BVy5QqkpUTBLDKmgwVJvfoTomvtqiViVhi8x0sLXB8DNz38lz92KtwPA8ZA>
X-ME-Proxy-Cause: dmFkZTE1dc9CbechtpXaWl+dm7IoP012eGu+JbmaMQmZ3E5PnUICFQoF84rE9FxW+eoV0N
    XbVHtzOC8A/iKr3YxvxxEGlhIVSoVA0ELtjoQuWqoRvcJJTE8jzJihiWJ0FLNyqMzf/uUL
    ncAYArvR9mUpu9BXiGC//bgv/8XcXCJdx+V9rpCY8UHd+FX4tCNOqOkTE4ek9QCCLFp6Fe
    ftd/fXGKyVhYeNrysK6DQqvZoebt/zzww4Iv5ye12W+andjR2gG/QXZ4Xka2v+ZSrng2tZ
    Ho3bYFyxbAuYc36s69aRDDrbvhO8L1Iys3CTKcc5diyM7p78MhxhhSEoTocjZC4WrO76No
    62ziB3wkww419qqj6KGV5PPjpVQGzkVrZM75D1iFWyEyeJ47WOU1nbOgwKwJp3rn2VpixO
    nu8wei88nKeZAJKYCCzyagJcG4VMZ8xe6cpSSM/KAtF0JLIYkkyudJOuDTdf/PZ2s5IoEG
    sKh+JNCWEST2pz7PYlGN07zC5PbuLSUsdKvxqooG956BZq2NkMI8okEM5/uNFxiwnpLGpe
    FoSy3wIhsbEhwMt8U5roFoRJSgzAjzxzLs4e1pKoxHlB7t33biCOVY6zOCdUceGUBMSlDk
    DYmuF0StS07DL2KqdcrEEQA4kPie1Bbp9yB9fxZhhm4gQMhwz0t/ha6+HkXA
X-ME-Proxy: <xmx:gap6ap9jCUepx8n1FcSiVcS5dEYu8oJdINHtjw-zHCsFCcZTrraSJw>
    <xmx:gap6arihgGtK9lwCJFNHuyjdtnjWgwxYY8FeALzded4LdoQkiLcA2Q>
    <xmx:gap6an6qkh1A-fGAL8NjV_EeT6yCTalTmUIp52EiKLwPe2yyXbunDQ>
    <xmx:gap6aobSnyNCcWW0-TDM9qWJd6ujLIl_ItjIMyxSZXovdquRMury8g>
    <xmx:gqp6aqkl2hQ7wjyWLuvarOIcNnODXYbALCir6xSeyr5wNfOh-GpnSsUZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 11 Aug 2026 00:52:11 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Miklos Szeredi" <miklos@szeredi.hu>
Cc: "Ian Kent" <raven@themaw.net>, "Chuck Lever" <cel@kernel.org>,
 "Jake Edge" <jake@lwn.net>, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, "Jan Harkes" <jaharkes@cs.cmu.edu>,
 coda@cs.cmu.edu, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jan Kara" <jack@suse.cz>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>,
 "Andrew Morton" <akpm@linux-foundation.org>,
 "Miklos Szeredi" <mszeredi@redhat.com>, autofs@vger.kernel.org,
 linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org,
 codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 04/12] fsnotify: reduce i_lock hold time in
 fsnotify_set_children_dentry_flags()
In-reply-to:
 <CAJfpegv2TTEGgfFBvAB1j2ixyEMXruG0AhL=R9iMC-LMJToiAg@mail.gmail.com>
References: <20260803012648.2195405-1-neilb@ownmail.net>
  <20260803012648.2195405-5-neilb@ownmail.net>
  <CAJfpegv2TTEGgfFBvAB1j2ixyEMXruG0AhL=R9iMC-LMJToiAg@mail.gmail.com>
Date: Tue, 11 Aug 2026 14:52:08 +1000
Message-id: <178642392818.2852630.1335784298767574361@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
> 
> > +       /* Find the dentry for inode - there can only be one */
> > +       for_each_alias(alias, inode)
> > +               break;
> > +       dget(alias);
> 
> This is __d_find_dir_alias().

True.

> 
> Could add a get_dir_alias() primitive that does the i_lock locking as well?

We already have d_find_alias() and d_find_any_alias().
They seem much the same for directories, so I'll use d_find_alias().

Thanks for the suggestion.

NeilBrown


> 
> Thanks,
> Miklos
> 

