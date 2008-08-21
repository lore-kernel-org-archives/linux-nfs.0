From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Thu, 21 Aug 2008 18:54:13 -0400
Message-ID: <20080821225413.GD4076@fieldses.org>
References: <20080820200827.GC21226@fieldses.org> <76bd70e30808201319j7b59de5gc912fcd01594e8@mail.gmail.com> <20080820204751.GE21226@fieldses.org> <76bd70e30808201419g5171d7eob7e6b57dd735e07d@mail.gmail.com> <20080820212902.GH21226@fieldses.org> <76bd70e30808201507l44c85d08o3ec4e8eeb7edda5e@mail.gmail.com> <20080820233024.GC28617@fieldses.org> <76bd70e30808201900r699ca044o884584ecedc6a799@mail.gmail.com> <20080821204620.GD29466@fieldses.org> <76bd70e30808211522k7cb6846fs4e371c8003320fe7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chucklever@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54703 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbYHUWyP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2008 18:54:15 -0400
In-Reply-To: <76bd70e30808211522k7cb6846fs4e371c8003320fe7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2008 at 06:22:02PM -0400, Chuck Lever wrote:
> I don't think you want to add a lot of specialized logic in
> nfs4namespace.c or client.c or where ever that has to figure out what
> a valid IP address string looks like.  Just hand the referral hostname
> string to the super.c address parser.  That's what it's there for.
> 
> If something comes out, it's almost sure to be a valid address.  If
> you have a scope ID too, then it's unsupported for now, and punt.  You
> can also explicitly check for a link-local address (there is a
> facility for that) and punt in that case too.

The case where the scope id is bad or the kstrndup() in
nfs_parse_ipv6_scope_id fails seems to be indistinguishable from the
case where there is no scope id specified.

So if I want to rule out scope id's in the referred-to server name
entirely, then I do need to continue checking for that before calling.

--b.
