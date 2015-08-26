Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:35075 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbHZMB0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 08:01:26 -0400
Received: by qkbm65 with SMTP id m65so117387107qkb.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 05:01:25 -0700 (PDT)
Date: Wed, 26 Aug 2015 08:01:21 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Pratyush Anand <panand@redhat.com>
Cc: bfields@fieldses.org, rostedt@goodmis.org, linux-nfs@vger.kernel.org,
        Ingo Molnar <mingo@redhat.com>, "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@primarydata.com>,
        open list <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/2] net: sunrpc: fix tracepoint Warning: unknown op
 '->'
Message-ID: <20150826080121.6612852b@tlielax.poochiereds.net>
In-Reply-To: <20150826115225.GF13340@dhcppc13.redhat.com>
References: <cover.1440482404.git.panand@redhat.com>
	<edc9697b5140015b15c96cc1b505b3c53169e634.1440482404.git.panand@redhat.com>
	<20150826063103.6f036582@tlielax.poochiereds.net>
	<20150826115225.GF13340@dhcppc13.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 26 Aug 2015 17:22:25 +0530
Pratyush Anand <panand@redhat.com> wrote:

> Hi Jeff,
> 
> Thanks for your review comments.
> 
> On 26/08/2015:06:31:03 AM, Jeff Layton wrote:
> > On Tue, 25 Aug 2015 11:34:19 +0530
> > Pratyush Anand <panand@redhat.com> wrote:
> > >  	TP_fast_assign(
> > >  		__entry->xprt = xprt;
> > > +		__entry->addr =
> > > +			xprt ? (struct sockaddr *)&xprt->xpt_remote : NULL;
> > 
> > I don't get it. It's not safe to save a pointer to xprt and dereference
> > that in a tracepoint (and I understand why that is), but it is safe to
> > save a pointer to a structure embedded inside of xprt? Shouldn't you be
> > saving a copy of the entire sockaddr struct instead?
> 
> As far as "saving of a pointer to a structure embedded inside of xprt" is
> concerned, I do not see any issue.
> 
> Its your take that what you want to print as your tracepoint print output. I
> might be missing something..  However, I do not see any value addition in
> printing address of a structure(located in ring buffer) where xprt->xpt_remote
> has been copied.
> 
> > 
> > Ahh, ok -- I think I see the confusion. %pIScp does not print the
> > address of the sockaddr, but instead dereferences the pointer and
> > prints it as a formatted address string. See pointer() in
> > lib/vsprintf.c. You do want to save off a copy of the structure instead.
> 
> In my opinion, saving of structure would only be necessary if you want to access
> element of the structure xprt->xpt_remote.
> 
> ~Pratyush

That's exactly what %pI does. Look at the pointer() function.

For this tracepoint, we want to print out the address of the remote end
of the socket. That's saved in xprt->xpt_remote.

%pIScp doesn't print the pointer's address. It dereferences that
pointer and formats and prints the socket address that it points to. If
you pass a NULL pointer into anything that uses %pI, it's going to oops.

-- 
Jeff Layton <jlayton@poochiereds.net>
