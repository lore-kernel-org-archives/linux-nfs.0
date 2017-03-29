Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34019 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756024AbdC2LBs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Mar 2017 07:01:48 -0400
Received: by mail-qk0-f178.google.com with SMTP id d10so9211146qke.1
        for <linux-nfs@vger.kernel.org>; Wed, 29 Mar 2017 04:01:47 -0700 (PDT)
Message-ID: <1490785302.2738.2.camel@poochiereds.net>
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Chuck Lever <chucklever@gmail.com>, linux-nfs@vger.kernel.org
Date: Wed, 29 Mar 2017 07:01:42 -0400
In-Reply-To: <20170329011638.GA20963@fieldses.org>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net>
         <1490577699.6879.1.camel@poochiereds.net>
         <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
         <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
         <1490612833.2808.1.camel@poochiereds.net>
         <1490618353.6879.3.camel@poochiereds.net>
         <20170329011638.GA20963@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-03-28 at 21:16 -0400, J. Bruce Fields wrote:
> On Mon, Mar 27, 2017 at 08:39:13AM -0400, Jeff Layton wrote:
> > Something like this patch maybe? Builds but is otherwise untested. It
> > might not DTRT though in the (nonsensical) case where you have a server
> > that is listening on UDP but doesn't support v2 or v3. Not sure I
> > really care about that too much.
> 
> I don't think this is worth the trouble.
> 
> A client that attempts to mount NFSv4 over UDP is operating out of spec,
> and we don't owe them much.
> 
> I'm not even convinced that transport-specific high/low version returns
> are correct.  A client could in theory be configured to prefer UDP and
> NFSv3, but to fall back to NFSv4 and TCP if NFSv3 was unavailable, and
> this would break that.  That would be legal but admittedly odd client
> behavior.
> 

That's fine with me. My rationale here was that we have to treat each
listening socket as a different "remote", in RPC parlance, since not all
versions are supported on all socket types.

Again though, the version info reported here is pretty useless.

> If somebody actually hits a case where this patch would help, then let's
> reconsider.
> 

Fine by me.
-- 
Jeff Layton <jlayton@poochiereds.net>
