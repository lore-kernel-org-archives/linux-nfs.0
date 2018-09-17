Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:53090 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727698AbeIRDaV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Sep 2018 23:30:21 -0400
Date: Mon, 17 Sep 2018 18:01:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180917220107.GB21269@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
 <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2018 at 02:37:16PM -0700, Stan Hu wrote:
> On Mon, Sep 17, 2018 at 2:15 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > Sounds like a bug to me, but I'm not sure where.  What filesystem are
> > you exporting?  How much time do you think passes between steps 1 and 4?
> > (I *think* it's possible you could hit a bug caused by low ctime
> > granularity if you could get from step 1 to step 4 in less than a
> > millisecond.)
> 
> For CentOS, I am exporting xfs. In Ubuntu, I think I was using ext4.
> 
> Steps 1 through 4 are all done by hand, so I don't think we're hitting
> a millisecond issue. Just for good measure, I've done experiments
> where I waited a few minutes between steps 1 and 4.
> 
> > Those kernel versions--are those the client (node A and B) versions, or
> > the server versions?
> 
> The client and server kernel versions are the same across the board. I
> didn't mix and match kernels.
> 
> > > Note that with an Isilon NFS server, instead of seeing stale content,
> > > I see "Stale file handle" errors indefinitely unless I perform one of
> > > the corrective steps.
> >
> > You see "stale file handle" errors from the "cat test1.txt"?  That's
> > also weird.
> 
> Yes, this is the problem I'm actually more concerned about, which led
> to this investigation in the first place.

It might be useful to look at the packets on the wire.  So, run
something on the server like:

	tcpdump -wtmp.pcap -s0 -ieth0

(replace eth0 by the relevant interface), then run the test, then kill
the tcpdump and take a look at tmp.pcap in wireshark, or send tmp.pcap
to the list (as long as there's no sensitive info in there).

What we'd be looking for:
	- does the rename cause the directory's change attribute to
	  change?
	- does the server give out a delegation, and, if so, does it
	  return it before allowing the rename?
	- does the client do an open by filehandle or an open by name
	  after the rename?

--b.
