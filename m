Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754998AbaAFPE1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 10:04:27 -0500
Date: Mon, 6 Jan 2014 10:04:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140106150425.GA29923@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
 <1388579314-15255-2-git-send-email-jlayton@redhat.com>
 <20140102212149.GC28219@fieldses.org>
 <20140106093744.14fc3670@notabene.brown>
 <20140105204516.51aa31ad@corrin.poochiereds.net>
 <1388990173.26102.69.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388990173.26102.69.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 06, 2014 at 01:36:13AM -0500, Simo Sorce wrote:
> On Sun, 2014-01-05 at 20:45 -0500, Jeff Layton wrote:
> > On Mon, 6 Jan 2014 09:37:44 +1100
> > NeilBrown <neilb@suse.de> wrote:
> > 
> > > On Thu, 2 Jan 2014 16:21:50 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> > > wrote:
> > > 
> > > > On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > > > > It doesn't make much sense to make reads from this procfile hang. As
> > > > > far as I can tell, only gssproxy itself will open this file and it
> > > > > never reads from it. Change it to just give the present setting of
> > > > > sn->use_gss_proxy without waiting for anything.
> > > > 
> > > > I think my *only* reason for doing this was to give a simple way to wait
> > > > for gss-proxy to start (just wait for a read to return).
> > > > 
> > > > As long as gss-proxy has some way to say "I'm up and running", and as
> > > > long as that comes after writing to use-gss-proxy, we're fine.
> > > > 
> > > 
> > > 
> > > Only tangentially related to the above email .....
> > > 
> > > I had a look at this new-fangled gssproxy thing and while it mostly seems
> > > like a good idea, I find the hard-coding of "/var/run/gssproxy.sock" in the
> > > kernel source .... disturbing.
> > > You never know when some user-space might want to change that - maybe to
> > > "/run/gssproxy.sock" (unlikely I know - but possible).
> > > 
> > > Probably the easiest would be to hand the path to the kernel.
> > > 
> > > e.g. instead  of writing '1' to "use-gss-proxy", we could 
> > >   echo /my/path/gss-proxy-sock > /proc/net/rpc/use-gss-proxy
> > > 
> > > Then you could even use an 'abstract' socket name if you wanted. i.e. one
> > > starting with a nul and which doesn't exist anywhere in the filesystem.
> > > I would feel a lot more comfortable with that than with the current
> > > hard-coding.
> > > 
> > 
> > I like that idea -- particularly if you keep the legacy behavior that
> > writing a '1' to the file makes it default to /var/run/gssproxy.sock so
> > we don't break compatability with older gssproxy releases.
> 
> I have no problem adding this to gss-proxy but I wonder if it is really
> that important.
> 
> In what case gss-proxy will not be able to create a file
> named /var/run/gssproxy.sock ? The only case would be for the distro to
> outlaw creating a path named /var/run, note that /var/run does not need
> to be the same as /run for gssproxy to be able to create a socket.

Well, I suppose we could fix the hard-coded kernel paths but still leave
it hard-coded in gss-proxy until someone demonstrated a need for it to
be configurable.

I like the principle but don't see this as a very high priority.

--b.
