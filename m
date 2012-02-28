Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48316 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757211Ab2B1M5y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 07:57:54 -0500
Date: Tue, 28 Feb 2012 07:57:41 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: Harshula <harshula@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        NeilBrown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: "Using NFS over UDP on high-speed links such as Gigabit can
 cause silent data corruption."
Message-ID: <20120228075741.2966a530@tlielax.poochiereds.net>
In-Reply-To: <20120228124646.GA2528@umich.edu>
References: <1330406521.9157.16.camel@serendib>
	<20120228065218.7e110936@tlielax.poochiereds.net>
	<20120228124646.GA2528@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 28 Feb 2012 07:46:46 -0500
Jim Rees <rees@umich.edu> wrote:

> Jeff Layton wrote:
> 
>   On Tue, 28 Feb 2012 16:22:01 +1100
>   Harshula <harshula@redhat.com> wrote:
>   
>   > Hi Steve,
>   > 
>   > The following openSUSE nfs-utils patch, warn-nfs-udp.patch, is not
>   > included upstream:
>   > 
>   > https://build.opensuse.org/package/view_file?file=warn-nfs-udp.patch&package=nfs-utils&project=openSUSE%3AFactory&rev=8e3e60c70e8270cd4afa036e13f6b2bb
>   > 
>   > Please consider including it.
>   > 
>   > Thanks,
>   > #
>   > 
>   
>   I think that patch looks reasonable and clearly documenting the
>   problems with UDP is a wonderful thing.
>   
>   It may be best to send it formally to steved and the list as a real
>   [PATCH] with a real description and SoB line.
> 
> This feels like the wrong place to document this, since it affects anything
> that uses udp, not just nfs.  It also seems like this should be solved in
> the network layer with an adaptive frag time.  But I'm not volunteering to
> do that.

Certainly, documenting it in udp(7) or whatever would be fine too. The
problem though is that someone setting up a NFS mount isn't as likely
to see it there as they would if it were in nfs(5).

I see no harm in documenting it here too. At the very least, if you're
going to put this into udp(7) instead then nfs(5) should refer to that
manpage and chapter explicitly.

-- 
Jeff Layton <jlayton@redhat.com>
