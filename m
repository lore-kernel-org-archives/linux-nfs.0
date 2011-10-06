Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33661 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758305Ab1JFNOe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 09:14:34 -0400
Message-ID: <4E8DA9A9.5010205@parallels.com>
Date: Thu, 06 Oct 2011 17:14:17 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
References: <20111005150214.GA18449@fieldses.org> <4E8C9363.9030303@parallels.com> <20111005181959.GB18449@fieldses.org> <4E8D7BED.6020705@parallels.com> <4E8D9F3F.4090004@parallels.com> <20111006131109.GB21627@fieldses.org>
In-Reply-To: <20111006131109.GB21627@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/06/2011 05:11 PM, J. Bruce Fields wrote:
> On Thu, Oct 06, 2011 at 04:29:51PM +0400, Pavel Emelyanov wrote:
>>>> Also, do you think per-namespace version support is important?
>>>>
>>>
>>> Actually, yes, I do.
>>> As I see it, nfsd filesystem have to virtualized to provide flexible control for 
>>> server features. If so, then we need to virtualize program as well.
>>
>> ACK - per namespace version control is required as well.
>>
>> AFAIK it's performed via sysctl-s and this part (sysctls engine I mean) is already
>> namespaces aware, thus it will not be the hard part of the implementation :)
> 
> It's a special file in the nfsd filesystem.  But I assume that won't be
> a big deal either.

Well, yes, you're right :)

> By the way, I'm curious: as we do this virtualization step-by-step, is
> there any way for userspace to tell how far we've gotten?
> 
> So for example if you have a system that's configured to use some new
> namespace-based feature, and you boot it to an old kernel, is there some
> way for it to check at the start and say "sorry, this isn't going to
> work"?

M-m... I'd say - there's no automatic way for doing this. What we can (and probably
should) do is - audit the nfs/nfsd subsystems and mark places with
   if (ns != &init_net_ns)
          return -EOPNOTSUPP
and remove these parts eventually.

> --b.
> .
> 

