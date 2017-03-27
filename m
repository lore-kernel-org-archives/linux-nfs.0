Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35310 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdC0LO7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Mar 2017 07:14:59 -0400
Received: by mail-qk0-f175.google.com with SMTP id r142so5912887qke.2
        for <linux-nfs@vger.kernel.org>; Mon, 27 Mar 2017 04:14:58 -0700 (PDT)
Message-ID: <1490612833.2808.1.camel@poochiereds.net>
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Jeff Layton <jlayton@poochiereds.net>
To: Chuck Lever <chuck.lever@oracle.com>,
        Chuck Lever <chucklever@gmail.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Date: Mon, 27 Mar 2017 07:07:13 -0400
In-Reply-To: <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
         <1490577699.6879.1.camel@poochiereds.net>
         <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
         <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2017-03-26 at 22:41 -0400, Chuck Lever wrote:
> > On Mar 26, 2017, at 10:38 PM, Chuck Lever <chucklever@gmail.com> wrote:
> > 
> > Hey Jeff-
> > 
> > 
> > > > On Mar 26, 2017, at 9:21 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> > > > 
> > > > On Sun, 2017-03-26 at 19:27 -0400, Chuck Lever wrote:
> > > > Same change as Kinglong Mee's fix for the TCP backchannel service.
> > > > 
> > > 
> > > Good catch. I guess I didn't do a good job of hunting down all of the
> > > transports where this needed to be set. I'll give them another pass
> > > again tomorrow to make sure I didn't miss any others.
> > > 
> > > > Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
> > > > Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> > > > ---
> > > > Some (perhaps late) review comments on 5283b03ee5cd:
> > > > 
> > > > I have reservations about returning RPC_PROG_MISMATCH in this case.
> > > > RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
> > > > not an RPC-level error, thus reporting the problem here seems like a
> > > > layering violation.
> > > > 
> > > > I'm not sure why an explicit check is needed: if the server isn't
> > > > listening on UDP, wouldn't clients see a transport-level rejection
> > > > (like ECONNREFUSED)?
> > > > 
> > > 
> > > Sure, if the server isn't listening on UDP...
> > > 
> > > The point of that patch is to enforce not allowing v4 over UDP when the
> > > server is listening on UDP to serve earlier versions.
> > > 
> > > As far as the error...From RFC 5531:
> > > 
> > >            PROG_UNAVAIL  = 1, /* remote hasn't exported program  */
> > >            PROG_MISMATCH = 2, /* remote can't support version #  */
> > > 
> > > Consider the case where the server is listening on both TCP and UDP,
> > > and is serving both v3 and v4. Someone tries to send a v4 RPC over UDP.
> > > 
> > > The RPC program in that case (nfs) is supported over UDP, but the
> > > version (v4) is not. So I disagree here. PROG_MISMATCH seems like the
> > > better fit to me.
> > 
> > Then the server should report the correct version range in the
> > rejection. The RPC response I saw on the wire claimed that 4
> > was the maximum supported version.
> 
> Of course, versions 2 and 3 do not make sense for
> the backchannel. So I'm not sure what you would report
> in that case.
> 

Yeah, that's clearly a bug. The problem is that we currently track
min/max versions on a per-program basis, but really we need to track
them per-program + per-transport.

Another way to fix it would be to set that info more dynamically at the
time of the error. Walk the pg_vers array and if we're on a non-
congestion control transport, skip any entries that require it.

That said, I'm not aware of anything that actually uses that version
info, aside from people poking around at it with rpcinfo. Is there
anything that actually does? If not, then I'm not terribly concerned
about getting it right, though it would be nice to have.

-- 
Jeff Layton <jlayton@poochiereds.net>
