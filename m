Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2215 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932103Ab2GMPzr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jul 2012 11:55:47 -0400
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20120713154500.GB32660@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
	 <20120713154500.GB32660@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 Jul 2012 11:55:45 -0400
Message-ID: <1342194945.2718.66.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-07-13 at 11:45 -0400, J. Bruce Fields wrote:
> On Fri, May 25, 2012 at 06:09:52PM -0400, Simo Sorce wrote:
> > This patchset implements a new upcall mechanism that uses the sunrpc
> > client to talk to gssproxy[1], a new userspace daemon that handles gssapi
> > operations on behalf of other processes on the system.
> > 
> > The main driver for this new mechanism is to overcome limitations with
> > the current daemon and upcall. The current code cannot handle tickets
> > larger than approximatively 2k and cannot handle sending back large user
> > credential sets to the kernel.
> > 
> > These patches have been tested against the development version of gssproxy
> > tagged as kernel_v0.1 in the master repo[2].
> > 
> > I have tested walking into mountpoints using tickets artificially pumped
> > up to 64k and the user is properly authorized, after the accept_se_context
> > call is performed through the new upcall mechanism and gssproxy.
> > 
> > The gssproxy has the potential of handling also init_sec_context calls,
> > but at the moment the only targeted system is nfsd.
> 
> Something I forgot to ask about.  (Or I did ask and forgot to take notes
> on the answer!): how is gssproxy doing the principal->(uid, gid's)
> mapping?
> 
> (svcgssd uses libnfsidmap--which I don't particularly like, but if
> gssproxy is doing something different then we need to figure out how the
> transition will work).

At the moment gss-proxy uses the standard gss_localname() function to
find out what user a principal maps to. Then a normal getpwnam() to get
the user's ids followed by a getgrouplist() for the groups.

I thought of using libnfsidmap but to be honest it makes little sense,
it is its own island of configuration that is different from the rest of
the system and I could not figure out why nfs should behave differently
from the rest of the system.

If there is a good reason I can link against the library in gss-proxy,
although I'd rather take the ball for unifying mapping so that it
behaves uniformly across the system rather than keeping custom mappings
that may different between apps and filesystem.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

