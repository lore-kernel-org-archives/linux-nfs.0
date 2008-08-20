From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Wed, 20 Aug 2008 19:30:24 -0400
Message-ID: <20080820233024.GC28617@fieldses.org>
References: <20080814223028.GN23859@fieldses.org> <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com> <20080820200827.GC21226@fieldses.org> <76bd70e30808201319j7b59de5gc912fcd01594e8@mail.gmail.com> <20080820204751.GE21226@fieldses.org> <76bd70e30808201419g5171d7eob7e6b57dd735e07d@mail.gmail.com> <20080820212902.GH21226@fieldses.org> <76bd70e30808201507l44c85d08o3ec4e8eeb7edda5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38455 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbYHTXaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 19:30:25 -0400
In-Reply-To: <76bd70e30808201507l44c85d08o3ec4e8eeb7edda5e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 06:07:50PM -0400, Chuck Lever wrote:
> What may be confusing you is that scope delimiters are used almost
> exclusively for link-local addresses, which are valid only on the
> local host.
> 
> If you don't want to handle a referral that uses a link-local address,
> or you don't want to handle a link-local address with a scope ID, then
> there are explicit checks you can do.

Well, the current code does allow a referral to point to 127.0.0.1.  I
don't know what to think of that; it seems unlikely to be useful for
anything but testing, and possibly succeptible to abuse, but of course
the protocol doesn't forbid it.

I google around a bit, but still don't get the scope stuff.  Are they
really part of an "ipv6 address"?  I thought an ipv6 address was just a
128-bit number?  (Or do they just give another way of writing something
that you could already write without the %?)

--b.
