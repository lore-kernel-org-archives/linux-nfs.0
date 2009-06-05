From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 5 Jun 2009 12:38:28 -0400
Message-ID: <20090605163828.GG10975@fieldses.org>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <20090605161027.GF10975@fieldses.org> <4D090F4F-4063-429C-829B-E56A1B127D3B@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35336 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbZFEQi3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 12:38:29 -0400
In-Reply-To: <4D090F4F-4063-429C-829B-E56A1B127D3B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2009 at 12:14:48PM -0400, Chuck Lever wrote:
>
> On Jun 5, 2009, at 12:10 PM, J. Bruce Fields wrote:
>
>> On Fri, Jun 05, 2009 at 07:36:48AM -0400, Jeff Layton wrote:
>>> Eventually, we most distros are going to want to build nfs-utils
>>> against libtirpc in order to get IPv6 support. At some point, we'll
>>> probably want to make building with IPv6 support the default. In the
>>> meantime however, we need to get more testing exposure for the TI-RPC
>>> codepaths. We'll probably start building Fedora's nfs-utils with TI- 
>>> RPC
>>> support in the near future.
>>>
>>> The question that Steve D. has asked is whether we should also make
>>> --enable-tirpc the default for the mainline nfs-utils tree?
>>>
>>> Doing this now would add wider testing exposure for these codepaths  
>>> and
>>> help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
>>> new library dependency for packagers, or they'll need to take the
>>> conscious step to --disable-tirpc when they configure.
>>>
>>> We could make it so that configure looks for libtirpc and if it's not
>>> available, configures the build against legacy RPC interfaces. I  
>>> think
>>> this is a bad idea however. While it should "just work" either way,
>>> there are some small behavioral differences when TIRPC support is  
>>> built
>>> in. I think it's probably better to make enabling and disabling  
>>> TIRPC a
>>> conscious step.
>>>
>>> Thoughts?
>>
>> Makes sense to me to have upstream defaults set to what we expect
>> distributions to move to, assuming there aren't known regressions.
>
> That's a big assumption,

I'm confused--there are known regressions or there aren't.  (I'm not
talking about unknown regressions....)

> and it's exactly why we wanted to have some  soak time in rawhide or
> Debian unstable before enabling it by default  upstream.

I don't think upstream needs to be more conservative than the
development distro's.

--b.
