Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34210 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729618AbeIRXwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Sep 2018 19:52:50 -0400
Date: Tue, 18 Sep 2018 14:19:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180918181901.GC1218@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
 <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org>
 <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2018 at 03:48:12PM -0700, Stan Hu wrote:
> I'm not sure if the binary pcap made it on the list, but here's s a
> publicly available link:
> https://s3.amazonaws.com/gitlab-support/nfs/nfs-rename-test1.pcap.gz
> 
> Some things to note:
> 
> * 10.138.0.14 is the NFS server.
> * 10.138.0.12 is Node A (the NFS client where the RENAME happened).
> * 10.138.0.13 is Node B (the NFS client that has test.txt open and the cat loop)
> 
> * Packet 13762 shows the first RENAME request, which the server
> responds with an NFS4ERR_DELAY
> * Packet 13769 shows an OPEN request for "test.txt"
> * Packet 14564 shows the RENAME retry
> * Packet 14569 the server responded with a RENAME NFS4_OK
> 
> I don't see a subsequent OPEN request after that. Should there be one?

Yes.

We know node B has that cat loop that will keep reopening the file.

The only way node B could avoid translating those open syscalls into
on-the-wire OPENs is if the client holds a delegation.

But it can't hold a delegation on the file that was newly renamed to
test.txt--delegations are revoked on rename, and it would need to do
another OPEN after the rename to get a new delegation.  Similarly the
file that gets renamed over should have its delegation revoked--and we
can see that the client does return that delegation.  The OPEN here is
actually part of that delegation return process--the CLAIM_DELEGATE_CUR
value on "claim type" is telling the server that this is an open that
the client had cached locally under the delegation it is about to
return.

Looks like a client bug to me, possibly some sort of race handling the
delegation return and the new open.

It might help if it were possible to confirm that this is still
reproduceable on the latest upstream kernel.

--b.

> 
> On Mon, Sep 17, 2018 at 3:16 PM Stan Hu <stanhu@gmail.com> wrote:
> >
> > Attached is the compressed pcap of port 2049 traffic. The file is
> > pretty large because the while loop generated a fair amount of
> > traffic.
> >
> > On Mon, Sep 17, 2018 at 3:01 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > On Mon, Sep 17, 2018 at 02:37:16PM -0700, Stan Hu wrote:
> > > > On Mon, Sep 17, 2018 at 2:15 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > >
> > > > > Sounds like a bug to me, but I'm not sure where.  What filesystem are
> > > > > you exporting?  How much time do you think passes between steps 1 and 4?
> > > > > (I *think* it's possible you could hit a bug caused by low ctime
> > > > > granularity if you could get from step 1 to step 4 in less than a
> > > > > millisecond.)
> > > >
> > > > For CentOS, I am exporting xfs. In Ubuntu, I think I was using ext4.
> > > >
> > > > Steps 1 through 4 are all done by hand, so I don't think we're hitting
> > > > a millisecond issue. Just for good measure, I've done experiments
> > > > where I waited a few minutes between steps 1 and 4.
> > > >
> > > > > Those kernel versions--are those the client (node A and B) versions, or
> > > > > the server versions?
> > > >
> > > > The client and server kernel versions are the same across the board. I
> > > > didn't mix and match kernels.
> > > >
> > > > > > Note that with an Isilon NFS server, instead of seeing stale content,
> > > > > > I see "Stale file handle" errors indefinitely unless I perform one of
> > > > > > the corrective steps.
> > > > >
> > > > > You see "stale file handle" errors from the "cat test1.txt"?  That's
> > > > > also weird.
> > > >
> > > > Yes, this is the problem I'm actually more concerned about, which led
> > > > to this investigation in the first place.
> > >
> > > It might be useful to look at the packets on the wire.  So, run
> > > something on the server like:
> > >
> > >         tcpdump -wtmp.pcap -s0 -ieth0
> > >
> > > (replace eth0 by the relevant interface), then run the test, then kill
> > > the tcpdump and take a look at tmp.pcap in wireshark, or send tmp.pcap
> > > to the list (as long as there's no sensitive info in there).
> > >
> > > What we'd be looking for:
> > >         - does the rename cause the directory's change attribute to
> > >           change?
> > >         - does the server give out a delegation, and, if so, does it
> > >           return it before allowing the rename?
> > >         - does the client do an open by filehandle or an open by name
> > >           after the rename?
> > >
> > > --b.
