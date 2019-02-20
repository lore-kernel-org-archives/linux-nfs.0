Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9EC1C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:46:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9E1202146F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:46:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=themaw.net header.i=@themaw.net header.b="BJxsv+b4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="wsFWPPwd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729194AbfBTCqg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 21:46:36 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35681 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725616AbfBTCqf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 21:46:35 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 20FAF233AB;
        Tue, 19 Feb 2019 21:46:34 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Tue, 19 Feb 2019 21:46:34 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=themaw.net; h=
        message-id:subject:from:to:cc:date:in-reply-to:references
        :content-type:mime-version:content-transfer-encoding; s=fm2; bh=
        YqCbabGzvKCWGS13EUnOLA95VIhsqfmIn0nslossjtk=; b=BJxsv+b4YoQRjux5
        EFeAe/StoQCwvFdf3CVkcspwiHI8omrukwadCqNMdubj21xp+AvPXot9bP8TW6dG
        vsBWhzLVk4Pra+n4G+4hywvor3VBovJhJjBPndH2LehOkCpbidcmbGBwagBbiWNd
        FRyeLR6OuDh1esODhoEeSnDzjaQHHeey6eFmdrrGLAgLWDf8fgTxXOWzqWZpbxe9
        aWHUuN6iyhmV69msFcM2uMFgYvZXyWdJjIZEPeTDvBdfKh7cwLLZvhM5dYsajqm5
        /YXSazduDV9HtaAjBc+IxiIehqCPYtpSWaDCNbO6uWyrxwEQAqOdTVPwSUpPJtrD
        e7MvwQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:content-type
        :date:from:in-reply-to:message-id:mime-version:references
        :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
        :x-sasl-enc; s=fm2; bh=YqCbabGzvKCWGS13EUnOLA95VIhsqfmIn0nslossj
        tk=; b=wsFWPPwd4B/kLjwCxJOwpE7PfKSfJ1xUL+EtjnfaWtupzWeRs/K6cLQSK
        oJjTWYv/nqUl2Q6BN2g0ABPr7+WjwGK+/EsQuSGZ0UiW8wbyTAEZVThACHHpKh+g
        vVk9Bg7AbD/ljf5Hqdz0LmVtO75hD9OHNI2G0dg+69nXRS9LtHKnLo8fBKE2U28X
        fFH92DBYBanVewp6IUvMkJtDIDhSTAc8jKvE7v9gVzYVk1SeE0gfzhY4g5LRLbUV
        1CyrKho578883F9jVfvOAonTzTUf7UijWCCNmD6a5uL0hMxWlMmAad4D0hFYIKlF
        U04m/MaanRWbzlrrNWqK/HYM2L6JQ==
X-ME-Sender: <xms:iL9sXPg-mpLvZXx-9dr1NUx73NrUJj6aVSn1H2PKGGXSZBHX6Z3-Cg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrtdehgdehvdculddtuddrgedtledrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepkffuhffvffgjfhgtofgggfesthejredtredtjeenucfhrhhomhepkfgrnhcu
    mfgvnhhtuceorhgrvhgvnhesthhhvghmrgifrdhnvghtqeenucfkphepuddukedrvddtke
    drheehrdeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehrrghvvghnsehthhgvmhgrfidr
    nhgvthenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:iL9sXHftdWs8pa6mBabBlElwNUyxOp1tNr_jNR43qRhfKHM2LS2bUQ>
    <xmx:iL9sXCkZLligRfdy8ymOdJYjrYUwte0-qJd46qLQ0oHEM75OVyFHYA>
    <xmx:iL9sXAtzNNEFu6LkuvTQj_ivt_8fZjcV6LaTikqtG3pFPckO8vFk0g>
    <xmx:ir9sXGiAPqRXfbpMcFt-YryH_j2kPx57PYup1vdOH_on3V3BGbmFpg>
Received: from localhost (unknown [118.208.55.8])
        by mail.messagingengine.com (Postfix) with ESMTPA id E2C3910312;
        Tue, 19 Feb 2019 21:46:27 -0500 (EST)
Message-ID: <7923d4aa646fbe4bd71cfb4144f1c96f28cad972.camel@themaw.net>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
From:   Ian Kent <raven@themaw.net>
To:     David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Date:   Wed, 20 Feb 2019 10:46:24 +0800
In-Reply-To: <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
         <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-15 at 16:07 +0000, David Howells wrote:
> Implement a kernel container object such that it contains the following
> things:
> 
>  (1) Namespaces.
> 
>  (2) A root directory.
> 
>  (3) A set of processes, including one designated as the 'init' process.

Yeah, I think a name other than init needs to be used for this
process.

The problem being that there is no requirement for container
process 1 to behave in any way like an "init" process is
expected to behave and that leads to confusion (at least
it certainly did for me).

Admittedly I haven't yet worked through the series but in the
light of the comments from James I wanted to chime in (probably
too early to be useful not having read the series but ...).

I believe what your trying to do here is so badly needed it
would be great if the needs of James could be met to some
(as yet undefined) satisfactory extent.

Would there be any possibility of introducing a concept of
inactive and active containers where the creation is a two
(maybe more) step procedure, first the creation of (if you like
a "true") container that's essentially empty, basically a shell
(not the program "shell" of course), inert wrt. events and such
and implement the ability to make the container active by adding
various things, like processes, to it?

Clearly the concepts of inactive and active require a definition
of what they mean and I don't have that, perhaps a starting point
could be a container that has a process 1 (which should also require
a root fs and namespaces) is active otherwise it's considered inactive.

Ian

