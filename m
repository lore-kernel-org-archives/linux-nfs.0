Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753878AbcCONUA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Mar 2016 09:20:00 -0400
Date: Tue, 15 Mar 2016 09:19:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: William Dauchy <wdauchy@gmail.com>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: drop reference when
 sunrpc_cache_pipe_upcall() detects a race
Message-ID: <20160315131959.GA419@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name>
 <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 15, 2016 at 01:43:37PM +0100, William Dauchy wrote:
> Hello,
> 
> On Mon, Mar 14, 2016 at 9:38 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Sorry for the delay.  I agree, it seems simple enough; applying for
> > 4.6....
> 
> It it something we can consider for stable?

It's an unlikely-looking race, I haven't seen it reported in the wild,
and the consequences are just a reference-count leak (though admittedly
those can sometimes cause crashes later--I haven't checked for that
here).

So I wasn't planning too, but any additional information's welcomed.

--b.
