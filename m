Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76606C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 10:39:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 43A7E2077B
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 10:39:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=themaw.net header.i=@themaw.net header.b="GdEPYxMb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="lsrh/F4D"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727694AbfBUKjk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 05:39:40 -0500
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:53807 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725858AbfBUKjj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Feb 2019 05:39:39 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 20D7822C10;
        Thu, 21 Feb 2019 05:39:38 -0500 (EST)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Thu, 21 Feb 2019 05:39:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=themaw.net; h=
        message-id:subject:from:to:cc:date:in-reply-to:references
        :content-type:mime-version:content-transfer-encoding; s=fm2; bh=
        Uaa/0hfg8tP1tjTHmXAh+kdi/c3dztko9C7AEJ26rSQ=; b=GdEPYxMbMf1jOx/U
        TE9HslfNFKHfRpRsKvIgWMCqc8mZRORhhQ6CbcQA6YVeeUX9bwe52kBbk5gdSAV4
        MCvpph1Iv/jZzIcmXb7mAeC1pDE0GqIGmHwQmDg1bAKwDpcX+Vv0XrcBiCKNBvqA
        ER3B5H6Vxr4x5YGXugU2jDtbunvm5PltmYTkZn8katVFbN2qcZ/Hx9wWARO1MFyW
        RpPZF6ZRFlesnaALZWdtD5kKR/0RwlaCt2tBP+BvYuvNgoeAB56NYotXLjGn5Bfl
        PvhgqjPFCIOeHS1i0wSY2TufFhLTUbGW+FAPPbEKVKFe2J/TVq6qrR9fLgQFNTMv
        jBpUxw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:content-type
        :date:from:in-reply-to:message-id:mime-version:references
        :subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
        :x-sasl-enc; s=fm2; bh=Uaa/0hfg8tP1tjTHmXAh+kdi/c3dztko9C7AEJ26r
        SQ=; b=lsrh/F4DGGMiguGFk34zW05/mlcKC3GSK6J1NhsA+sF68YGzD+3Dj0TlX
        HUEzPFekQIE5/M1m03lGziQDY944UX/ZpQ8AzEZb6y4HlQiJrjSzYSzY9ZOgCD+a
        bxdLPodCYR0PDRj0a4uqASXLyikRuq99K6fBjplvVuFDXt52HoDYyQw57bNBzJrh
        xR9R+QQ0C53aWwyjjbTYxhqbDDstmTtStpTfavDWmoAdX02YBBazcSRAJLnVtBs6
        YtkWMdb0MJihSmTcxxtMF6ivLUFUST+T387mutiHxJO/ts4VvflAGel5D7oycpsV
        CJc4XV2ic9idLzPQFRw107RFjABQw==
X-ME-Sender: <xms:6X9uXKm0lAurBsguUih-a1Jf13ia7fYKw2C8rSllE3c2_EMTLPwDlg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrtdekgdduleculddtuddrgedtledrtddtmd
    cutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepkffuhffvffgjfhgtofgggfesthekredtredtjeenucfhrhhomhepkfgrnhcu
    mfgvnhhtuceorhgrvhgvnhesthhhvghmrgifrdhnvghtqeenucfkphepuddukedrvddtke
    drheehrdeknecurfgrrhgrmhepmhgrihhlfhhrohhmpehrrghvvghnsehthhgvmhgrfidr
    nhgvthenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:6X9uXNj4m3CdsT4bDf71AoJxUlPOMzcq3anSpGm0OulcAOegj2YbMA>
    <xmx:6X9uXAr4yjv_6YSEl-IhkPlkDDxWzuDnbAqry-Jw8tWW48dMU3esGA>
    <xmx:6X9uXMsnN2q7FAl-BmVu5eVx7CdgOG80dvM51P_3opzReEJJ1E6rNQ>
    <xmx:6n9uXEdxewVZp-0LW2ksSqJwkZ9OHOoo_Il7r1PbgR97y67tjTCaJg>
Received: from localhost (unknown [118.208.55.8])
        by mail.messagingengine.com (Postfix) with ESMTPA id 3CD661030F;
        Thu, 21 Feb 2019 05:39:31 -0500 (EST)
Message-ID: <6c907b21aca7b93c3b637ba0e30de4c6acb356f4.camel@themaw.net>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
From:   Ian Kent <raven@themaw.net>
To:     Christian Brauner <christian@brauner.io>
Cc:     David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Date:   Thu, 21 Feb 2019 18:39:28 +0800
In-Reply-To: <20190220132600.c5ahsmnoihdrcqeq@brauner.io>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
         <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
         <7923d4aa646fbe4bd71cfb4144f1c96f28cad972.camel@themaw.net>
         <20190220132600.c5ahsmnoihdrcqeq@brauner.io>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 2019-02-20 at 14:26 +0100, Christian Brauner wrote:
> On Wed, Feb 20, 2019 at 10:46:24AM +0800, Ian Kent wrote:
> > On Fri, 2019-02-15 at 16:07 +0000, David Howells wrote:
> > > Implement a kernel container object such that it contains the following
> > > things:
> > > 
> > >  (1) Namespaces.
> > > 
> > >  (2) A root directory.
> > > 
> > >  (3) A set of processes, including one designated as the 'init' process.
> > 
> > Yeah, I think a name other than init needs to be used for this
> > process.
> > 
> > The problem being that there is no requirement for container
> > process 1 to behave in any way like an "init" process is
> > expected to behave and that leads to confusion (at least
> > it certainly did for me).
> 
> If you look at the documentation for pid namespaces(7) you can see that
> the pid 1 inside a pid namespace is expected to behave like an init
> process:
> -  "The  first  process created in a new namespace [...] has  the PID 1,
>    and is the "init" process for the namespace (see init(1))."
> - "[...] child process that is orphaned within the namespace will be
>   reparented to this process rather than init(1) [...]"
> - "If the "init" process of a PID namespace terminates, the kernel
>   terminates all of the processes in the  namespace  via a SIGKILL
>   signal. This behavior reflects the fact that the "init" process is
>   essential for the cor‐ rect operation of a PID namespace."
> - "Only signals for which the "init" process has established a signal
>   handler can be sent to the  "init" process by other members of the
>   PID namespace."
> - "[...] the reboot(2) system call causes a signal to be sent to the
>   namespace "init" process."
> 
> This is one of the reasons why all major current container runtimes
> finally after years of failing to realize this run a stub init process
> that mimicks a dumb init. Sure, you get away with not having an init
> that behaves like an init but this is inherently broken or at least
> against the way pid namespaces were designed.

TBH I wasn't sure why the signal I sent didn't arrive, AFAICS
it should have regardless of what signals the container init
process was accepting. But it could have been due to a
different problem in my kernel code (that's very likely).

In any case it wasn't worth perusing because even if I did work
it out I had already found that the request_key sub-system wasn't
playing well with others when trying to run something within a
container's namespaces, so no point in going further ...

Ian

