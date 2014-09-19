Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57787 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757276AbaISSLX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 14:11:23 -0400
Date: Fri, 19 Sep 2014 14:11:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
Message-ID: <20140919181122.GC16658@fieldses.org>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
 <20140919155733.GA16658@fieldses.org>
 <541C5A55.7010403@RedHat.com>
 <20140919163617.GB16658@fieldses.org>
 <20140919130752.2ac3372e@willson.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140919130752.2ac3372e@willson.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 19, 2014 at 01:07:52PM -0400, Simo Sorce wrote:
> On Fri, 19 Sep 2014 12:36:17 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, Sep 19, 2014 at 12:31:17PM -0400, Steve Dickson wrote:
> > > 
> > > 
> > > On 09/19/2014 11:57 AM, J. Bruce Fields wrote:
> > > > On Fri, Sep 19, 2014 at 08:51:41AM -0400, Steve Dickson wrote:
> > > >> The gssproxy(8) daemon is now how the managing of GSSAPI 
> > > >> credentials should be done. 
> > > >>
> > > >> These to patches has the nfs-server systemd script start 
> > > >> gssproxy instead of rpc.svcgssd and removes the building 
> > > >> and installation of rpc.svcgssd.
> > > >>
> > > >> For now I'm leaving the source files... Just in case... ;-)
> > > > 
> > > > If nothing else, we'd like to keep support for older kernels for a
> > > > while.
> > > Good point... I should probably make this a configurable...
> > > something like --enable_svcgssd and have it off by default...
> > 
> > Sounds fine.
> 
> +1, it will be very useful for transitions in distributions, not all of
> them will align identically I guess.

If we wanted to be *very* nice, we could try to detect and run one or
the other at run-time.  It's nice for people trying to boot old kernels
to track down (probably unrelated) regressions.  But I think it would be
too complicated.

It might be simple enough for gss-proxy to log some kind of warning when
it starts up on an old kernel.

--b.
