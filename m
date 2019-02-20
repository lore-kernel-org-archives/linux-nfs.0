Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACEAFC10F00
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 757E921738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=themaw.net header.i=@themaw.net header.b="mzGXpx49";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="R919zaAg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730349AbfBTDEM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:12 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42181 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727576AbfBTDEM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:12 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 68C752298D;
        Tue, 19 Feb 2019 22:04:10 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute1.internal (MEProxy); Tue, 19 Feb 2019 22:04:10 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=themaw.net; h=
        message-id:subject:from:to:cc:date:in-reply-to:references
        :content-type:mime-version:content-transfer-encoding; s=fm2; bh=
        lhrEKsiGJGNA6Yykbb1WVVrSHLLSRrEk4pRPv8DNIJE=; b=mzGXpx49IDlH1VB4
        Bi8lQH2VFQUIxDGLEGKsei+RPH+Gm3b7NyRMEpJJpOcDXodE74GHLxpsd937JvVM
        F4Kg5Q9TatoeQ5oBfvbRKq6f8PCoShF3C8G4Y0Trtd057KySePz429rP7R6kBZCt
        lLwRFkLKK4K9ggAxGP6ob5NaFaTiOA0F3412fFu5ZUdD1T53LG+XHw59D8o9Oc86
        49VY/kSrtpZEB4d+ZfOlVvL9nq/CEty/1zhb04AL89edNgJ77VDmZNYfjeJK7cw1
        6a/MDk4HpBmTjJIWniK7jGQ8EET1T9YxOyYpZaitoeYES+qUrR7SRcaNqyVBsm+/
        lAsZGg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:content-type
        :date:from:in-reply-to:message-id:mime-version:references
        :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
        :x-sasl-enc; s=fm2; bh=lhrEKsiGJGNA6Yykbb1WVVrSHLLSRrEk4pRPv8DNI
        JE=; b=R919zaAgo0erWzQ/Culs0+vIBA1pzpijlqgiE8DK4CvBZa/GJoZCs/RmP
        Gwo/KHh7xxQF+cVh06J5VrwYznaSQ054oXQ14lrobBp3jWhKMI4uja6tYf9d3/x9
        3rx/ARFRKaUhVjRduUrFdv7l6YLoZSr+d25FTA1ozMHxI+XHSTCbvakUrkzBCFV3
        7rFVR2qOz1moh+1BI/Ebw9lUDiQZmFvQYWZgBGhrGpcnQ+a1Ox2Xaly/VFpu1nXv
        U6a33M7C64EPAupHP4vilyQYWDyzNMrMhhN6BS/rOlAmP1B9NmUSdTabX0b70LXT
        E2pjvh8DSSBq2vduBcy/VvAE3UDGA==
X-ME-Sender: <xms:qcNsXJiNpNzgfbVn7ZEXjNt5beJazQXfgVeJMKxrLRzfEHsszweCLA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrtdehgdehheculddtuddrgedtledrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepkffuhffvffgjfhgtofgggfesthejredtredtjeenucfhrhhomhepkfgrnhcu
    mfgvnhhtuceorhgrvhgvnhesthhhvghmrgifrdhnvghtqeenucfkphepuddukedrvddtke
    drheehrdeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehrrghvvghnsehthhgvmhgrfidr
    nhgvthenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:qcNsXKkTVK9AT3rDd8H8IuipirkmMehXXFUA8ZzueNvJ43dvy2RJbQ>
    <xmx:qcNsXN8EbtMKYEy4WXtPRo9WAKKQdkIX2SsgUuYtv-c-JRQlYJCrYg>
    <xmx:qcNsXOlkE1nnIw4w43OIKSL-0fLLJm0QKnfmDeFA6J-dOkfWRYz-Qw>
    <xmx:qsNsXJZLCZRlcAygvIlyqtOaaWkaB02YSoB0BMwUR90Qp_65BxM2nQ>
Received: from localhost (unknown [118.208.55.8])
        by mail.messagingengine.com (Postfix) with ESMTPA id 0936EE409E;
        Tue, 19 Feb 2019 22:04:04 -0500 (EST)
Message-ID: <054c1e762d28306abd4db9c42fb1c5f4261332fd.camel@themaw.net>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
From:   Ian Kent <raven@themaw.net>
To:     James Bottomley <James.Bottomley@HansenPartnership.com>,
        David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Date:   Wed, 20 Feb 2019 11:04:01 +0800
In-Reply-To: <1550629220.11684.3.camel@HansenPartnership.com>
References: <1550432358.2809.21.camel@HansenPartnership.com>
         <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
         <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
         <19562.1550617574@warthog.procyon.org.uk>
         <1550629220.11684.3.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2019-02-19 at 18:20 -0800, James Bottomley wrote:
> On Tue, 2019-02-19 at 23:06 +0000, David Howells wrote:
> > James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> > 
> > > I thought we got agreement years ago that containers don't exist in
> > > Linux as a single entity: they're currently a collection of cgroups
> > > and namespaces some of which may and some of which may not be local
> > > to the entity the orchestration system thinks of as a "container".
> > 
> > I wasn't party to that agreement and don't feel particularly bound by
> > it.
> 
> That's not at all relevant, is it?  The point is we have widespread
> uses of namespaces and cgroups that span containers today meaning that
> a "container id" becomes a problematic concept.  What we finally got to
> with the audit people was an unmodifiable label which the orchestration
> system can set ... can't you just use that?

Sorry James, I fail to see how assigning an id to a collection of objects
constitutes a problem or how that could restrict the way a container is
used.

Isn't the only problem here the current restrictions on the way objects
need to be combined as a set and the ability to be able add or subtract
from that set.

Then again the notion of active vs. inactive might not be sufficient to
allow for the needed flexibility ...

Ian

