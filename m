Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60181 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758284Ab1JFNLK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 09:11:10 -0400
Date: Thu, 6 Oct 2011 09:11:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
Message-ID: <20111006131109.GB21627@fieldses.org>
References: <20111005150214.GA18449@fieldses.org>
 <4E8C9363.9030303@parallels.com>
 <20111005181959.GB18449@fieldses.org>
 <4E8D7BED.6020705@parallels.com>
 <4E8D9F3F.4090004@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E8D9F3F.4090004@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 06, 2011 at 04:29:51PM +0400, Pavel Emelyanov wrote:
> >> Also, do you think per-namespace version support is important?
> >>
> > 
> > Actually, yes, I do.
> > As I see it, nfsd filesystem have to virtualized to provide flexible control for 
> > server features. If so, then we need to virtualize program as well.
> 
> ACK - per namespace version control is required as well.
> 
> AFAIK it's performed via sysctl-s and this part (sysctls engine I mean) is already
> namespaces aware, thus it will not be the hard part of the implementation :)

It's a special file in the nfsd filesystem.  But I assume that won't be
a big deal either.

By the way, I'm curious: as we do this virtualization step-by-step, is
there any way for userspace to tell how far we've gotten?

So for example if you have a system that's configured to use some new
namespace-based feature, and you boot it to an old kernel, is there some
way for it to check at the start and say "sorry, this isn't going to
work"?

--b.
