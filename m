Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59682 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751454AbaAEWyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 5 Jan 2014 17:54:21 -0500
Date: Sun, 5 Jan 2014 17:54:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140105225421.GA24059@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
 <1388579314-15255-2-git-send-email-jlayton@redhat.com>
 <20140102212149.GC28219@fieldses.org>
 <20140106093744.14fc3670@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140106093744.14fc3670@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 09:37:44AM +1100, NeilBrown wrote:
> On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > > It doesn't make much sense to make reads from this procfile hang. As
> > > far as I can tell, only gssproxy itself will open this file and it
> > > never reads from it. Change it to just give the present setting of
> > > sn->use_gss_proxy without waiting for anything.
> > 
> > I think my *only* reason for doing this was to give a simple way to wait
> > for gss-proxy to start (just wait for a read to return).
> > 
> > As long as gss-proxy has some way to say "I'm up and running", and as
> > long as that comes after writing to use-gss-proxy, we're fine.
> > 
> 
> 
> Only tangentially related to the above email .....
> 
> I had a look at this new-fangled gssproxy thing and while it mostly seems
> like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in the
> kernel source .... disturbing.
> You never know when some user-space might want to change that - maybe to
> "/run/gssproxy.sock" (unlikely I know - but possible).
> 
> Probably the easiest would be to hand the path to the kernel.
> 
> e.g. instead  of writing '1' to "use-gss-proxy", we could 
>   echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy
> 
> Then you could even use an 'abstract' socket name if you wanted. i.e. one
> starting with a nul and which doesn't exist anywhere in the filesystem.
> I would feel a lot more comfortable with that than with the current
> hard-coding.

See also RPCBIND_SOCK_PATHNAME.  (I *think* that's completely hardcoded,
not just a default.)

I get the general principle.  I have a hard time seeing how it would be
a problem in practice.

If we wanted to do as you suggest, I suppose we could even special-case
the string "1" (at least for a while) to make the change
backwards-compatible.

I'd like to see the same argument made for the rpcbind case.

--b.
