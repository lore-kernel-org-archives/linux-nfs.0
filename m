From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Wed, 20 Aug 2008 17:29:02 -0400
Message-ID: <20080820212902.GH21226@fieldses.org>
References: <20080814223028.GN23859@fieldses.org> <52C9C44B-750E-437C-B3E8-380DB7371629@oracle.com> <20080820200827.GC21226@fieldses.org> <76bd70e30808201319j7b59de5gc912fcd01594e8@mail.gmail.com> <20080820204751.GE21226@fieldses.org> <76bd70e30808201419g5171d7eob7e6b57dd735e07d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56043 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbYHTV3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 17:29:08 -0400
In-Reply-To: <76bd70e30808201419g5171d7eob7e6b57dd735e07d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 20, 2008 at 05:19:50PM -0400, Chuck Lever wrote:
> On Wed, Aug 20, 2008 at 4:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Aug 20, 2008 at 04:19:48PM -0400, Chuck Lever wrote:
> >> On Wed, Aug 20, 2008 at 4:08 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> > On Fri, Aug 15, 2008 at 12:59:09PM -0400, Chuck Lever wrote:
> >> >> On Aug 14, 2008, at 6:30 PM, J. Bruce Fields wrote:
> >> >>> I was looking back at this bug with the misparsing of
> >> >>> (non-mull-terminated) fs_locations attributes.  Thanks to the work on
> >> >>> nfs_parse_server_address, etc., we can now also more easily support
> >> >>> ipv6
> >> >>> addresses here.  But I got lost in the usual maze of twisty struct
> >> >>> sockaddr_*'s, all alike.  Is this right?  Does any of it need to be
> >> >>> under CONFIG_IPV6?  Is there a simpler way?
> >> >>
> >> >> The use of the new address parser looks correct, but your string
> >> >> handling needs work.  :-)
> >> >>
> >> >> Comments below...
> >> >
> >> > Pffft.  My hope that someone else would pick this up for me was
> >> > obviously fantasy. OK, thanks for comments:
> >> >
> >> >>> diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
> >> >>> index b112857..c0f5191 100644
> >> > ...
> >> >>> +                    if (memchr(buf->data, '%', buf->len))
> >> >>> +                            goto next;
> >> >>
> >> >> Why are you looking for a '%' ?
> >> >
> >> > Would it have been clearer if I'd moved the IPV6_SCOPE_DELIMITER define
> >> > to a common header?  I don't think that has any place in the nfs
> >> > protocol.  And we've got less trust in the address we're parsing here
> >> > (which came across the wire) then we would in a mount commandline.
> >>
> >> OK, so you wanted a scope delimiter.  Why do you want to punt IPv6
> >> addresses that have a scope delimiter?  Sorry to be dense.
> >
> > The thing we're parsing here is a hostname that the server returned to
> > us.  It should be either a dns name (which we don't handle yet) or an ip
> > address.  The scope-delimiter thing isn't legal.
> 
> Scope delimiters are legal in IPv6 addresses.  Unfortunately I can't
> find the relevant RFC at the moment.

Oh, OK, I think I took a quick look and assumed they were something that
only made sense locally.  I'll look again.

--b.
