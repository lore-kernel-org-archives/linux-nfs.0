Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E07BC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 13:26:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D1832086D
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 13:26:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="G2WBdU6b"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727751AbfBTN0K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 08:26:10 -0500
Received: from mail-wm1-f67.google.com ([209.85.128.67]:38573 "EHLO
        mail-wm1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725826AbfBTN0K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2019 08:26:10 -0500
Received: by mail-wm1-f67.google.com with SMTP id v26so6436473wmh.3
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 05:26:08 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=1JQam90U+6VOjJbiYx8tejOxAiXSTEoSs7kyr8I+VFw=;
        b=G2WBdU6bGnmGuvbpVAav4fL6NRioQgwohfgDFrrieMWMGgiT+Jg2vi/v+wWiXYMufa
         4C1z5B/kF1sYh8GGIpAUWVY3b1agcNyixvWIq+JhskHVIuW7yJ6fnSBNTMd7SACwp6c6
         D5ym2SUwCzj3JGI1bT2y5ybho+t8WhjNiRbfPTmIkZDcaJJbNUnS8w20ABrrBda45vql
         bYYzTY2aqeCiQVx2yaPV4BAnsPqAzOIbmJ9/+lqUtx5liYzsWHjmXK9y7gyR6J3AaJW8
         ujJ9vA/ycJlGuIWTk5meRwRknAxakE24vWEny5SsX+tUF8OK0w/eexPTrtZ9qv5UWABM
         hRww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=1JQam90U+6VOjJbiYx8tejOxAiXSTEoSs7kyr8I+VFw=;
        b=sV2GkJrOdbltmp0hjNGdmYgQ95SbKOvWv5grriyooe1pD5FWqyEW+vO0rfRi3OZaS+
         kts6cp06Bw05BGDcf3HeT+I+tYr/Sfq0Z2qNbZnXeQUDIY4dYNmzKOtC07B3ZKf+Sekp
         NqdWzyacSbbP+fKXJWZzALoNi2SfHbWwx0u6cSIQqFLRvDyztCuq122S3coIvHchUWJM
         a4LuOhfJAkP9VjjzNjyI1gLPPSgf8Wed9emzpZSQ3AyW2SSJ12YpByx3Olh1l8TXztTs
         DE2w3glzeuMkxsTHbPZgXXNlBZgZcHSZI492pJNS4Qf+jbJ588iU2qHRJqrB9IMT+0B2
         ZUzw==
X-Gm-Message-State: AHQUAuZlDmQtyurNmUXHb2sv9Tn5bad+i20YXs1M5q/uu3EN41CurmDD
        9sK2N1MhMmTd9816wYH4qDUDiw==
X-Google-Smtp-Source: AHgI3IbSRhSOCjOsYRy3P9yFqZXDL9xDOkY/2Z80pS6vYHEU364Y1PNIbuHS54Q+XWmcs0PYU/Sing==
X-Received: by 2002:a7b:c0c3:: with SMTP id s3mr6369747wmh.141.1550669167512;
        Wed, 20 Feb 2019 05:26:07 -0800 (PST)
Received: from brauner.io ([81.92.17.155])
        by smtp.gmail.com with ESMTPSA id j124sm5816696wmb.48.2019.02.20.05.26.04
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 20 Feb 2019 05:26:06 -0800 (PST)
Date:   Wed, 20 Feb 2019 14:26:02 +0100
From:   Christian Brauner <christian@brauner.io>
To:     Ian Kent <raven@themaw.net>
Cc:     David Howells <dhowells@redhat.com>, keyrings@vger.kernel.org,
        trond.myklebust@hammerspace.com, sfrench@samba.org,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
Message-ID: <20190220132600.c5ahsmnoihdrcqeq@brauner.io>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
 <7923d4aa646fbe4bd71cfb4144f1c96f28cad972.camel@themaw.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7923d4aa646fbe4bd71cfb4144f1c96f28cad972.camel@themaw.net>
User-Agent: NeoMutt/20180716
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 20, 2019 at 10:46:24AM +0800, Ian Kent wrote:
> On Fri, 2019-02-15 at 16:07 +0000, David Howells wrote:
> > Implement a kernel container object such that it contains the following
> > things:
> > 
> >  (1) Namespaces.
> > 
> >  (2) A root directory.
> > 
> >  (3) A set of processes, including one designated as the 'init' process.
> 
> Yeah, I think a name other than init needs to be used for this
> process.
> 
> The problem being that there is no requirement for container
> process 1 to behave in any way like an "init" process is
> expected to behave and that leads to confusion (at least
> it certainly did for me).

If you look at the documentation for pid namespaces(7) you can see that
the pid 1 inside a pid namespace is expected to behave like an init
process:
-  "The  first  process created in a new namespace [...] has  the PID 1,
   and is the "init" process for the namespace (see init(1))."
- "[...] child process that is orphaned within the namespace will be
  reparented to this process rather than init(1) [...]"
- "If the "init" process of a PID namespace terminates, the kernel
  terminates all of the processes in the  namespace  via a SIGKILL
  signal. This behavior reflects the fact that the "init" process is
  essential for the cor‐ rect operation of a PID namespace."
- "Only signals for which the "init" process has established a signal
  handler can be sent to the  "init" process by other members of the
  PID namespace."
- "[...] the reboot(2) system call causes a signal to be sent to the
  namespace "init" process."

This is one of the reasons why all major current container runtimes
finally after years of failing to realize this run a stub init process
that mimicks a dumb init. Sure, you get away with not having an init
that behaves like an init but this is inherently broken or at least
against the way pid namespaces were designed.
