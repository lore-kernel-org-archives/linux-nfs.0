Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab2B1MlZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 07:41:25 -0500
Date: Tue, 28 Feb 2012 07:41:21 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Harshula <harshula@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can
 cause silent data corruption."
Message-ID: <20120228074121.3cedb321@tlielax.poochiereds.net>
In-Reply-To: <1330432346.9157.30.camel@serendib>
References: <1330406521.9157.16.camel@serendib>
	<20120228065218.7e110936@tlielax.poochiereds.net>
	<1330432346.9157.30.camel@serendib>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Feb 2012 23:32:26 +1100
Harshula <harshula@redhat.com> wrote:

> On Tue, 2012-02-28 at 06:52 -0500, Jeff Layton wrote:
> > On Tue, 28 Feb 2012 16:22:01 +1100
> > Harshula <harshula@redhat.com> wrote:
> > 
> > > Hi Steve,
> > > 
> > > The following openSUSE nfs-utils patch, warn-nfs-udp.patch, is not
> > > included upstream:
> > > 
> > > https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb
> > > 
> > > Please consider including it.
> > > 
> > > Thanks,
> > > #
> > > 
> > 
> > I think that patch looks reasonable and clearly documenting the
> > problems with UDP is a wonderful thing.
> > 
> > It may be best to send it formally to steved and the list as a real
> > [PATCH] with a real description and SoB line.
> 
> I do not know who authored the above patch, hopefully someone will come
> out and claim it now that it is on this list.
> 
> cya,
> #
> 

Well, presumably that patch is open-source licensed like the rest of
the nfs-utils code. Is that sufficient to simply copy it from opensuse?

Either way, if the author were to step forward that would certainly be
preferable...

-- 
Jeff Layton <jlayton@redhat.com>
