Received: from fout-a7-smtp.messagingengine.com (fout-a7-smtp.messagingengine.com [103.168.172.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 510BE84039
	for <linux-nfs@vger.kernel.org>; Sat, 13 Jun 2026 01:09:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781312992; cv=none; b=O2n/AlIBt8siBsk3MQh0FA/NWUJJNwsx9Vg5xwFSHshu2CWovdCJuQfo9kA+/ntmFjN8xiTpCmFh+d5sG2xpyuzMnIbBvdb8zjya1562hpLM6r/dl4wdficcox223sSOwlKaP7Uv+iR2tM/8soGE0zZRswYXhwyXFzvsd3yRHFU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781312992; c=relaxed/simple;
	bh=ioqdK3PSYGPxv52oC508WwfX965/AfC7RonVHE6sS7I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=CeZt0/dHHc6ZW14JZfs4fSgokFCL/6wD+P9dZNk0/oAsUfINELdR2LFz7KQkc4nL3aNURV0Lwl/LGRVXrvV+9paUQjyNDNRV7ntUBZ9P++KpF1fcg081MuTs+uT577VsprKs5+Z2po+mqgb746PAq3Oq41Nah1rEnm8JOuXi3Xo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=b5+fJhVu; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=fRu+W5xB; arc=none smtp.client-ip=103.168.172.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="b5+fJhVu";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fRu+W5xB"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.phl.internal (Postfix) with ESMTP id 70188EC00A5;
	Fri, 12 Jun 2026 21:09:50 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 12 Jun 2026 21:09:50 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1781312990; x=1781399390; bh=Vu0jSmnb4fwVLEmo8rDaGYwxb0dNLrffNIK
	/WjYqZIc=; b=b5+fJhVuxkoQQflqMCzVikc4vwAvDCWyNGJQX+2fKVB+ukkHyPL
	+wqJ/P9aHrF26p2KkmwSzAEgb7MEAPYCQ11JjZIHlJ3sye0dgIt80H0w5ePa40u5
	mcDWF61EBRNfpeBQi2uyO39NYDBqLy102d314CBy7JrFPFTb19mV8igtvC5UcLoH
	dmsJISPcO4twkRaGwrAp7M0vP7K9IfoCt6B7yteIYWKJmznR8pZoYy2azngiC5sB
	Zy/GvwdTZI2vEl5K0hsxpKsjF75txjB1Khnxf53immmqB9zqT7/stQmwA1DMbGDm
	lim124GLHiLfn9SfRiSrJyDTJbp5cLsO7Jw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1781312990; x=
	1781399390; bh=Vu0jSmnb4fwVLEmo8rDaGYwxb0dNLrffNIK/WjYqZIc=; b=f
	Ru+W5xBzfe98dQB2mYeCg0lQPZNoOf5Ii7MWSIpl14nXqdcnC8m3b9AW7HW4l+C+
	AeCbjIKO2yDyb3fZfbpPhfhpXvS+Y2WtTxk2q86zjzL1ltzfJzLBqRuGy4NNnxT0
	TCgGtHcRbyAFrr9mqYFtReW79JEC3ImMwZfZd4rEtfbb49xWwYC7enGgFCH0mTOe
	X0nXqRc0m8ZPN5TN/uQjkz+eFWTx1OBmbzE28VrFQz8p7ObwNSGTS+0iQ1K+2zVk
	ZXDTPWRiUZrQDRnD4YTfqnDgG8m+P8UaCo60PQoNRRdnq9WwgOZHINkZUKmvYsKb
	YQqbE7Rfddbe9bsVLk+sQ==
X-ME-Sender: <xms:3q0satPMy0FJHXU5pRF8ag1wrFP_6Tui7uQwBn_XbBZnVIr6Jsyo9A>
    <xme:3q0sam-Ifk0YjcWW_d48sgraziOA41v47XmgEWqOUB7O0fZ2PLk3jahYKgjC224y_
    zuYeov80c2oYv8jfvJm4XmjEjfldwgmtQKf8LvOnp8UVW_QeUY>
X-ME-Received: <xmr:3q0sahTfsSNcV7qlhkGiD_gI6IduEGOsPO-KeqF_0B51hu0wn5AyEjn-ur51D0aEmli3naVfIvUnmUXvvmo-hG51BBhsiw8>
X-ME-Proxy-Cause: dmFkZTGuvfWkvRwhKYKsXkUEiKuhMjP+3ACoEbRamzwAY1HRXZ4VmuqvoGMKZkogYn+nmA
    2Qwi+h9NktgEtlTMinNY71LSLNue1oW2h9GcxswqiK7pSLt09dXUgnqDFGoHqNOiYwCbxM
    lBPC9JO+yjblqn2xR1BS9JPozdNf9pqyesE12knEvvcgcFiO/DaMvBRM1xeQbcfFxP87GY
    L5MIgA7KTpsOz/XCYM/wjMjUVHvxHAcdpVq4h61reXaVlywvhIzJzmPQmLo5z6T4F61n1/
    8F3VRogRwNMGKYTkRvFT4Q1OHiCY2UU2s+lUyF04jTw6Kub8Z1Qnx1I3o2fzLs+I5ZFbBT
    WDtvrs/vtQjTrwE6VoIaW8U/eMJeZc1z8hS1w2dVthzPQPpT1U+WmGYx1WK7dqIRJQnlKq
    lezJYwyLNze3YYV9p3fTKo7un1KJAyo1WwADlWUw+Pu9QMdjuBgK85m6TYtpxkuyRXUpAY
    KVORb6OTM/gDu3rVMJ/ogmTfbiZYE8ZiB6vdTnWhEoPBQiOUjAvVHDVrvelg8sMloA+1bc
    8ocNXD6XO6LJN1ROsWeIMiXPrzcLEVcHWx1A122ba7z4xteTTo8FuffPv3rIwgz89ZHW1k
    5T7VzTeX1Nmih4P4Th3EK4TvZeiH6oEDLAikXbWIXK/OngV3dtFmXU/viCYg
X-ME-Proxy: <xmx:3q0saokBuNi5ZfNMbCD2RG5mqqg3WDP0UoMaaBVn_b8u88AK8mEOlA>
    <xmx:3q0sahTzRn1G0Um0GqXrmpXETms355bv4pgbk_KA_c5xYkpk_BJMUg>
    <xmx:3q0samPFn9K4tKSbp2NCkuyeO_w0O-BMuxl0q43hctOM1qKUdYdhZQ>
    <xmx:3q0saqUQjZKeQmFTCv96Nnt-my4Y5PNLsxvZmIDlYZkGecMUmkumhA>
    <xmx:3q0saiMXPu5vhJ9RBqUTvdPKm_KFLROQKVdTITgGSDZ0xGNPXeKz0VMX>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 12 Jun 2026 21:09:48 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [RFC] knfsd: per-client fair scheduling to prevent single-client
 starvation
In-reply-to: <a6225380-8520-4789-a64d-b8b94310dd67@app.fastmail.com>
References: <D33770A1-9098-4F1A-93EF-590E6C0B7638@hammerspace.com>
  <473e337b-fabc-4884-a6c4-0f04b6874d0b@app.fastmail.com>
  <3AB7EB6A-B207-4B91-A695-66C4704D0E31@hammerspace.com>
  <4c5dbb98-0209-4572-8eac-1578536bbd78@app.fastmail.com>
  <AED22AED-E97D-40E3-9839-BF8307EF8B65@hammerspace.com>
  <1a5c70d8-e7f4-4671-a29a-023be7c107fc@app.fastmail.com>
  <178044079821.2082204.6117918610145832039@noble.neil.brown.name>
  <561e9ac6-348f-4d6d-b896-38dbe5ede3bc@app.fastmail.com>
  <20555E8B-0E49-4328-8B31-0F73C3D286FE@hammerspace.com>
  <178060780940.3392745.3574880233025675236@noble.neil.brown.name>
  <83C74302-2A2B-48B6-B0F0-D5E8CB487BBC@hammerspace.com>
  <a6225380-8520-4789-a64d-b8b94310dd67@app.fastmail.com>
Date: Sat, 13 Jun 2026 11:09:44 +1000
Message-id: <178131298496.3002522.17571001244333071969@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 06 Jun 2026, Chuck Lever wrote:
> On Fri, Jun 5, 2026, at 5:29 AM, Benjamin Coddington wrote:
> > Also, because knfsd doesn't have different resource pools for each version
> > we're going to want to continue to balance the pool for all versions
> > exported.
> 
> At a higher altitude, I am treating this issue as a partial DoS surface,
> so it does indeed have to be addressed for all NFS versions to eliminate
> that surface.
> 

I can't see that DoS is a useful way to look at this.  For that we would
need a threat model which I don't think we have.

The problem situations that have been mentioned involve actors that would
like to co-operate but have no obvious mechanism to enable that
co-operation.
For v4, I think session flow control should be the "obvious" mechanism.
For v3, nothing is obvious so we have to look at heuristics, classifying
by recent behaviour or some sort or identity.  We don't need a system
that is always perfect, just a system that clients are able to
co-operate with.

Thanks,
NeilBrown
