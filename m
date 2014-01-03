Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56440 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359AbaACQXU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 11:23:20 -0500
Date: Fri, 3 Jan 2014 11:23:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140103162319.GK28219@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
 <1388579314-15255-2-git-send-email-jlayton@redhat.com>
 <20140102212149.GC28219@fieldses.org>
 <20140102172651.559eaa48@tlielax.poochiereds.net>
 <20140102224009.GF28219@fieldses.org>
 <20140102182746.547964c0@tlielax.poochiereds.net>
 <1388736843.26102.33.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388736843.26102.33.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 03, 2014 at 03:14:03AM -0500, Simo Sorce wrote:
> On Thu, 2014-01-02 at 18:27 -0500, Jeff Layton wrote:
> > On Thu, 2 Jan 2014 17:40:10 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Jan 02, 2014 at 05:26:51PM -0500, Jeff Layton wrote:
> > > > On Thu, 2 Jan 2014 16:21:50 -0500
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Wed, Jan 01, 2014 at 07:28:30AM -0500, Jeff Layton wrote:
> > > > > > It doesn't make much sense to make reads from this procfile hang. As
> > > > > > far as I can tell, only gssproxy itself will open this file and it
> > > > > > never reads from it. Change it to just give the present setting of
> > > > > > sn->use_gss_proxy without waiting for anything.
> > > > > 
> > > > > I think my *only* reason for doing this was to give a simple way to wait
> > > > > for gss-proxy to start (just wait for a read to return).
> > > > > 
> > > > 
> > > > What wasn't clear to me is what would be doing this read.
> > > > 
> > > > I'll take it from your comment then that patch #1 is acceptable?
> > > 
> > > Yes.  Thanks!
> > > 
> > > > > As long as gss-proxy has some way to say "I'm up and running", and as
> > > > > long as that comes after writing to use-gss-proxy, we're fine.
> > > > > 
> > > > 
> > > > I'll let Simo confirm that that's what gssproxy does, but yes that is
> > > > the desired behavior. Typically this is done by ensuring that the parent
> > > > process when daemon()-izing doesn't exit until everything is ready.
> > > > 
> > > > If gssproxy does need to be changed for that, we have a library routine
> > > > now in nfs-utils that does this that you can likely copy (see
> > > > mydaemon()).
> > > 
> > > From a quick skim: looks like gss-proxy does this in init_server().  So
> > > I think it might need something like the below?
> > > 
> > > (Untested.  I spent a total of maybe five minutes looking at this code
> > > so have no idea what I'm doing.)
> > > 
> > > --b.
> > > 
> > > diff --git a/proxy/src/gssproxy.c b/proxy/src/gssproxy.c
> > > index 1fca922..a7cbd7c 100644
> > > --- a/proxy/src/gssproxy.c
> > > +++ b/proxy/src/gssproxy.c
> > > @@ -97,6 +97,12 @@ int main(int argc, const char *argv[])
> > >          exit(EXIT_FAILURE);
> > >      }
> > >  
> > > +    /*
> > > +     * special call to tell the Linux kernel gss-proxy is available.
> > > +     * Note this must be done before nfsd is started.
> > > +     */
> > > +    init_proc_nfsd(gpctx->config);
> > > +
> > >      init_server(gpctx->config->daemonize);
> > >  
> > >      write_pid();
> > > @@ -139,9 +145,6 @@ int main(int argc, const char *argv[])
> > >          }
> > >      }
> > >  
> > > -    /* special call to tell the Linux kernel gss-proxy is available */
> > > -    init_proc_nfsd(gpctx->config);
> > > -
> > >      ret = gp_workers_init(gpctx);
> > >      if (ret) {
> > >          exit(EXIT_FAILURE);
> > 
> > That doesn't look quite right to me. That has it calling init_proc_nfsd
> > before any of the unix sockets are set up.
> > 
> > I think gss-proxy will probably need to do something similar to what
> > mydaemon does; set up a pipe, and have the parent just block reading
> > from it until the child writes to it. At that point the parent can exit
> > and the pipe can be closed in the child.
> > 
> > See:
> > 
> >     http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=support/nfs/mydaemon.c;h=e885d60f3a808299730a4d62dec49142fdc3ba5f;hb=HEAD
> > 
> 
> I'll take a look tomorrow, I created upstream ticket #114 to track this.

Thanks!

I notice there's also sd_notify(3) which avoids the double-fork and
self-pipe, but you might consider that too much of a systemd dependency.

--b.
