Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC261C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 15:28:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D5A12081B
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 15:28:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ew7C/SFJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D5A12081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=roeck-us.net
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728211AbeKBAcS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 20:32:18 -0400
Received: from mail-pf1-f193.google.com ([209.85.210.193]:38260 "EHLO
        mail-pf1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727950AbeKBAcS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 20:32:18 -0400
Received: by mail-pf1-f193.google.com with SMTP id b11-v6so9506774pfi.5;
        Thu, 01 Nov 2018 08:28:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=UQwNdyZs7+NarOfK+icn1dwEf9p2K/3ed2HnMcVT/yY=;
        b=ew7C/SFJ6Ri3Bz6CSG3sxAVqWNf/agXmhpiWebq1zpcRYkwr7tp3dIZQVLRK6OPw1a
         WRMbhYedqjfYTTyn98qQkOyOkfk6t4GlxAu/KFTHCzsiqTslIFFXHqc83+iBxCD5zjhl
         u3h0Qo+EIYaoZ0HxHNf8IWFBQm6Kz8CUixslkxk5KedqD/dGrxqD9K/UsfRudc0H5veq
         05dUpHAjG9s5EvkLwE6RJF3+d4W8bfhgXYGBx4qChVRv3vmE3bJqOPhVpfqbzvPvnp3X
         MTkiJE7E80Is3fAMQWDEQtDQLZeT4OByi4H0ePAPkaFOoruc6sEeWUh0e+FJ3T6ePOd0
         nvBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=UQwNdyZs7+NarOfK+icn1dwEf9p2K/3ed2HnMcVT/yY=;
        b=Gzj1MNuFQO6aKQGmXsVRQrs0KWXrB2MSezK3zlEQUnetAd4U8dc/1Tz9EziTHXnPVe
         m+Mwi6OWhyrr16Xw6Z6skmDEJxSmM/FqOfDNob94Z8cL0T0j8nONLbVQoBbpmJqtLXfB
         CrYTnmcHoew7DU35SYc1J3LzB5f4EN5BzFfmkZuVvmOiINg2oQBzHlOjI92GwVZ8KDD1
         yu0mzR03jPoYoChTN+bn/A9ISmmjxC+pCYIJeb9WWHG109oq0EPv+Ucsw0XoXVnJTwDU
         M8cHcEIl6XFx3i/Y0hxkSK9d8ePHdnvn15VHM/XUTA0X0h7bk8AEtDabSUjAF33764cZ
         wTYg==
X-Gm-Message-State: AGRZ1gJho60qi6PPrBVo7+iT1Dn7x/6SA44fszjUXhQcCDeM9X3tRI4A
        R9SovqMwzERXFWLqvJwDjuk=
X-Google-Smtp-Source: AJdET5fmhmqkDC08+8WPv32oJZpErebY8qH/BIp2xCnqI/AxX/IZq4kpeLpsLQtf3LQwsCQQNvGbTg==
X-Received: by 2002:a63:cc51:: with SMTP id q17-v6mr7483905pgi.291.1541086131442;
        Thu, 01 Nov 2018 08:28:51 -0700 (PDT)
Received: from localhost ([2600:1700:e321:62f0:329c:23ff:fee3:9d7c])
        by smtp.gmail.com with ESMTPSA id n65-v6sm1848713pfi.185.2018.11.01.08.28.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 08:28:50 -0700 (PDT)
Date:   Thu, 1 Nov 2018 08:28:49 -0700
From:   Guenter Roeck <linux@roeck-us.net>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "paul.burton@mips.com" <paul.burton@mips.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jhogan@kernel.org" <jhogan@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "paulus@samba.org" <paulus@samba.org>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "benh@kernel.crashing.org" <benh@kernel.crashing.org>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Message-ID: <20181101152849.GC25346@roeck-us.net>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
 <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
 <291af20b-820e-e848-cf75-730024612117@roeck-us.net>
 <d7fe095d8d1f848b5742a5b3e8cce9f89e0c1c8d.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d7fe095d8d1f848b5742a5b3e8cce9f89e0c1c8d.camel@hammerspace.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 01, 2018 at 06:30:08AM +0000, Trond Myklebust wrote:
[ ... ]
> > 
> > For my part I agree that this would be a much better solution. The
> > argument
> > that it is not always absolutely guaranteed that atomics don't wrap
> > doesn't
> > really hold for me because it looks like they all do. On top of that,
> > there
> > is an explicit atomic_dec_if_positive() and
> > atomic_fetch_add_unless(),
> > which to me strongly suggests that they _are_ supposed to wrap.
> > Given the cost of adding a comparison to each atomic operation to
> > prevent it from wrapping, anything else would not really make sense
> > to me.
> 
> That's a hypothesis, not a proven fact. There are architectures out
> there that do not wrap signed integers, hence my question.
> 

If what you say is correct, the kernel is in big trouble on those architectures.
atomic_inc_return() is used all over the place in the kernel with the assumption
that each returned value differs from the previous value (ie the value is used
as cookie, session ID, or for similar purposes).

Guenter
