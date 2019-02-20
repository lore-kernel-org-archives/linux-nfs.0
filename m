Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F9F0C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 06:57:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 324182183F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 06:57:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore-com.20150623.gappssmtp.com header.i=@paul-moore-com.20150623.gappssmtp.com header.b="OcCZh083"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726527AbfBTG5s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 01:57:48 -0500
Received: from mail-lj1-f193.google.com ([209.85.208.193]:33355 "EHLO
        mail-lj1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725857AbfBTG5s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 01:57:48 -0500
Received: by mail-lj1-f193.google.com with SMTP id f24-v6so19847046ljk.0
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 22:57:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ncoDYnqxH3gs9Sc4jdqZc699sEVY31p6X34ojqSqzzM=;
        b=OcCZh083AzJ6sYc48woP23gRRbpaNKLC68TAdlArP77RO3+mrjVrj/iw4ZpWg3rNV3
         29swcTzY/zTMAOqxs45u579zp81oWJDiOwSJh6tom9D/tAOgnuzVSLlkcuqb8zkvn041
         kOisgtVcvn0D2ldK2m99xkgmKknYygp1QYdTxOKnNijCZ/APmJ7hGFeM3e3VsCDdMErt
         wx0sR0iBJ+9HphZXJkooMsrO2GYHiQuoD7D0L5Nb1CAmiVGw+uEgE5SHW+LeT4H60qrm
         snbkENIP97Ktg8O/dDr3jUbp95t4Oa9ezjlJLisfHr/j4+wT/VqcxY16IMT2kuOtYSUn
         LRcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ncoDYnqxH3gs9Sc4jdqZc699sEVY31p6X34ojqSqzzM=;
        b=QXSc1FUOUuzSEKOIkzQFFXP09beO4xt1vnZ8cIJUFiqaGL/YteuJyFIDnrm64D6XJ5
         jJ0mdZwRK/18q5z0Tydyn4ELLPF8m/XIw2rlzL7JP1ZU3NyP4RGZZW1lrPR5EMOJrORP
         SiG6sxrJUvfOmXv+4J7fBsAMQL3fKQv7MD/VMcVpdyj30TbVUEOknlUnFAZy3p/pgGFX
         ksu5ZFu0bY44p67O9e+myIBU3R6hdI8dDYg5GdPnCXEEeTay4Ghhxdzl2mlsrxAiuwCO
         1Yu7iBknG0GPE3/f/wgeU7sB6V5nLmGvgKqNNBhSV3gHxf7PTVQ89McnOWLeSfu983kn
         +mww==
X-Gm-Message-State: AHQUAuZI9Ws5DSE1C7EpXhQ9778YDL2Km35EY8H+6h115+kjoyigYlq0
        3BFXpN6WWgDEe8rxltb25cTUpPJ481+Ce6xNXrZ+
X-Google-Smtp-Source: AHgI3IYNFpwogVRQTUBcod7un1tdomwmO6KB9Kx4d3EN4057kTMV12Wev9+tRhU4ylfg5rpiF1lmm8LPwJmAQFU2rTo=
X-Received: by 2002:a2e:2419:: with SMTP id k25mr8500519ljk.38.1550645865873;
 Tue, 19 Feb 2019 22:57:45 -0800 (PST)
MIME-Version: 1.0
References: <1550432358.2809.21.camel@HansenPartnership.com>
 <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
 <19562.1550617574@warthog.procyon.org.uk> <1550629220.11684.3.camel@HansenPartnership.com>
 <054c1e762d28306abd4db9c42fb1c5f4261332fd.camel@themaw.net> <1550634367.11684.6.camel@HansenPartnership.com>
In-Reply-To: <1550634367.11684.6.camel@HansenPartnership.com>
From:   Paul Moore <paul@paul-moore.com>
Date:   Wed, 20 Feb 2019 01:57:34 -0500
Message-ID: <CAHC9VhQga+bSVEyKbAtfxDsV9RqK5Hv6h-cbs4ArQ3KedxvgpQ@mail.gmail.com>
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel objects
To:     James Bottomley <James.Bottomley@hansenpartnership.com>
Cc:     Ian Kent <raven@themaw.net>, David Howells <dhowells@redhat.com>,
        keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 19, 2019 at 10:46 PM James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Wed, 2019-02-20 at 11:04 +0800, Ian Kent wrote:
> > On Tue, 2019-02-19 at 18:20 -0800, James Bottomley wrote:
> > > On Tue, 2019-02-19 at 23:06 +0000, David Howells wrote:
> > > > James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> > > >
> > > > > I thought we got agreement years ago that containers don't
> > > > > exist in Linux as a single entity: they're currently a
> > > > > collection of cgroups and namespaces some of which may and some
> > > > > of which may not be local to the entity the orchestration
> > > > > system thinks of as a "container".
> > > >
> > > > I wasn't party to that agreement and don't feel particularly
> > > > bound by it.
> > >
> > > That's not at all relevant, is it?  The point is we have widespread
> > > uses of namespaces and cgroups that span containers today meaning
> > > that a "container id" becomes a problematic concept.  What we
> > > finally got to with the audit people was an unmodifiable label
> > > which the orchestration system can set ... can't you just use that?
> >
> > Sorry James, I fail to see how assigning an id to a collection of
> > objects constitutes a problem or how that could restrict the way a
> > container is used.
>
> Rather than rehash the whole argument again, what's the reason you
> can't use the audit label?  It seems to do what you want in a way that
> doesn't cause problems.  If you can just use it there's little point
> arguing over what is effectively a moot issue.

Ignoring for a moment whether or not the audit container ID is
applicable here, one of the things I've been focused on with the audit
container ID work is trying to make it difficult for other subsystems
to use it.  I've taken this stance not because I don't think something
like a container ID would be useful outside the audit subsystem, but
rather because I'm afraid of how it might be abused by other
subsystems and that abuse might threaten the existence of the audit
container ID.

If there is a willingness to implement a general kernel container ID
that behaves similarly to how the audit container ID is envisioned,
I'd much rather do that then implement something which is audit
specific.

-- 
paul moore
www.paul-moore.com
