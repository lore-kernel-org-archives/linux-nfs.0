Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756002AbaISRH5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 13:07:57 -0400
Date: Fri, 19 Sep 2014 13:07:52 -0400
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
Message-ID: <20140919130752.2ac3372e@willson.usersys.redhat.com>
In-Reply-To: <20140919163617.GB16658@fieldses.org>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
	<20140919155733.GA16658@fieldses.org>
	<541C5A55.7010403@RedHat.com>
	<20140919163617.GB16658@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Sep 2014 12:36:17 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Sep 19, 2014 at 12:31:17PM -0400, Steve Dickson wrote:
> > 
> > 
> > On 09/19/2014 11:57 AM, J. Bruce Fields wrote:
> > > On Fri, Sep 19, 2014 at 08:51:41AM -0400, Steve Dickson wrote:
> > >> The gssproxy(8) daemon is now how the managing of GSSAPI 
> > >> credentials should be done. 
> > >>
> > >> These to patches has the nfs-server systemd script start 
> > >> gssproxy instead of rpc.svcgssd and removes the building 
> > >> and installation of rpc.svcgssd.
> > >>
> > >> For now I'm leaving the source files... Just in case... ;-)
> > > 
> > > If nothing else, we'd like to keep support for older kernels for a
> > > while.
> > Good point... I should probably make this a configurable...
> > something like --enable_svcgssd and have it off by default...
> 
> Sounds fine.

+1, it will be very useful for transitions in distributions, not all of
them will align identically I guess.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
