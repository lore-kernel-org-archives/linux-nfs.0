From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 01:47:33 -0700
Message-ID: <20080918014733.3c9c362e.akpm@linux-foundation.org>
References: <124712.40022.qm@web32602.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54101 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbYIRIrn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 04:47:43 -0400
In-Reply-To: <124712.40022.qm-n7KXdZBPtPqvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Sep 2008 01:38:57 -0700 (PDT) Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org> wrote:

> > No.  mount(8) will pass unrecognised options straight down into the
> > filesystem driver.
> >
> 
>  Has that always been the case, or is it a recent change? I have to support RHEL4 userland, which is not really new.

It's been that way for ever and ever.  It's how all these guys:

y:/usr/src/25> grep Opt_ fs/*/super.c|wc
    781    2626   33703

get handled.
