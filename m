Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36622 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727371AbeITBlo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Sep 2018 21:41:44 -0400
Date: Wed, 19 Sep 2018 16:02:14 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180919200214.GB14422@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
 <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org>
 <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <20180918181901.GC1218@fieldses.org>
 <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 19, 2018 at 10:39:19AM -0700, Stan Hu wrote:
> On Tue, Sep 18, 2018 at 11:19 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > We know node B has that cat loop that will keep reopening the file.
> >
> > The only way node B could avoid translating those open syscalls into
> > on-the-wire OPENs is if the client holds a delegation.
> >
> > But it can't hold a delegation on the file that was newly renamed to
> > test.txt--delegations are revoked on rename, and it would need to do
> > another OPEN after the rename to get a new delegation.  Similarly the
> > file that gets renamed over should have its delegation revoked--and we
> > can see that the client does return that delegation.  The OPEN here is
> > actually part of that delegation return process--the CLAIM_DELEGATE_CUR
> > value on "claim type" is telling the server that this is an open that
> > the client had cached locally under the delegation it is about to
> > return.
> >
> > Looks like a client bug to me, possibly some sort of race handling the
> > delegation return and the new open.
> >
> > It might help if it were possible to confirm that this is still
> > reproduceable on the latest upstream kernel.
> 
> Thanks for that information. I did more testing, and it looks like
> this stale file problem only appears to happen when the NFS client
> protocol is 4.0 (via the vers=4.0 mount option). 4.1 doesn't appear to
> have the problem.
> 
> I've also confirmed this problem happens on the mainline kernel
> version (4.19.0-rc4). Do you have any idea why 4.1 would be working
> but 4.0 has this bug?

No.  I mean, the 4.1/4.0 differences are complicated, so it's not too
surprising a bug could hit one and not the other, but I don't have an
explanation for this one off the top of my head.

> https://s3.amazonaws.com/gitlab-support/nfs/nfs-4.0-kernel-4.19-0-rc4-rename.pcap
> is the latest capture that also includes the NFS callbacks. Here's
> what I see after the first RENAME from Node A:
> 
> Node B: DELEGRETURN StateId: 0xa93
> NFS server: DELEGRETURN
> Node A: RENAME From: test2.txt To: test.txt
> NFS server: RENAME
> Node B: GETATTR
> NFS Server: GETATTR (with old inode)
> Node B: READ StateId: 0xa93
> NFS Server: READ

Presumably the GETATTR and READ use a filehandle for the old file (the
one that was renamed over)?

That's what's weird, and indicates a possible client bug.  It should be
doing a new OPEN("test.txt").

Also, READ shouldn't be using the stateid that was returned in
DELEGRETURN.  And the server should reject any attempt to use that
stateid.  I wonder if you misread the stateids--may be worth taking a
closer look to see if they're really bit-for-bit identical.  (They're
128 bits, so that 0xa93 is either a hash or just some subset of the
stateid.)

(Apologies, I haven't gotten a chance to look at it myself.)

> In comparison, if I don't have a process with an open file to
> test.txt, things work and the trace looks like:
> 
> Node B: DELEGRETURN StateId: 0xa93
> NFS server: DELEGRETURN
> Node A: RENAME From: test2.txt To: test.txt
> NFS server: RENAME
> Node B: OPEN test.txt
> NFS Server: OPEN StateID: 0xa93
> Node B: CLOSE StateID: 0xa93
> NFS Server: CLOSE
> Node B: OPEN test.txt
> NFS Server: OPEN StateId: 0xa93
> Node B: READ StateID: 0xa93
> NFS Server: READ
> 
> In the first case, since the client reused the StateId that it should
> have released in DELEGRETURN, does this suggest that perhaps the
> client isn't properly releasing that delegation? How might the open
> file affect this behavior? Any pointers to where things might be going
> awry in the code base would be appreciated here.

I'd expect the first trace to look more like this one, with new OPENs
and CLOSEs after the rename.

--b.

> 
> 
> 
> >
> > --b.
> >
> > >
> > > On Mon, Sep 17, 2018 at 3:16 PM Stan Hu <stanhu@gmail.com> wrote:
> > > >
> > > > Attached is the compressed pcap of port 2049 traffic. The file is
> > > > pretty large because the while loop generated a fair amount of
> > > > traffic.
> > > >
> > > > On Mon, Sep 17, 2018 at 3:01 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > >
> > > > > On Mon, Sep 17, 2018 at 02:37:16PM -0700, Stan Hu wrote:
> > > > > > On Mon, Sep 17, 2018 at 2:15 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> > > > > >
> > > > > > > Sounds like a bug to me, but I'm not sure where.  What filesystem are
> > > > > > > you exporting?  How much time do you think passes between steps 1 and 4?
> > > > > > > (I *think* it's possible you could hit a bug caused by low ctime
> > > > > > > granularity if you could get from step 1 to step 4 in less than a
> > > > > > > millisecond.)
> > > > > >
> > > > > > For CentOS, I am exporting xfs. In Ubuntu, I think I was using ext4.
> > > > > >
> > > > > > Steps 1 through 4 are all done by hand, so I don't think we're hitting
> > > > > > a millisecond issue. Just for good measure, I've done experiments
> > > > > > where I waited a few minutes between steps 1 and 4.
> > > > > >
> > > > > > > Those kernel versions--are those the client (node A and B) versions, or
> > > > > > > the server versions?
> > > > > >
> > > > > > The client and server kernel versions are the same across the board. I
> > > > > > didn't mix and match kernels.
> > > > > >
> > > > > > > > Note that with an Isilon NFS server, instead of seeing stale content,
> > > > > > > > I see "Stale file handle" errors indefinitely unless I perform one of
> > > > > > > > the corrective steps.
> > > > > > >
> > > > > > > You see "stale file handle" errors from the "cat test1.txt"?  That's
> > > > > > > also weird.
> > > > > >
> > > > > > Yes, this is the problem I'm actually more concerned about, which led
> > > > > > to this investigation in the first place.
> > > > >
> > > > > It might be useful to look at the packets on the wire.  So, run
> > > > > something on the server like:
> > > > >
> > > > >         tcpdump -wtmp.pcap -s0 -ieth0
> > > > >
> > > > > (replace eth0 by the relevant interface), then run the test, then kill
> > > > > the tcpdump and take a look at tmp.pcap in wireshark, or send tmp.pcap
> > > > > to the list (as long as there's no sensitive info in there).
> > > > >
> > > > > What we'd be looking for:
> > > > >         - does the rename cause the directory's change attribute to
> > > > >           change?
> > > > >         - does the server give out a delegation, and, if so, does it
> > > > >           return it before allowing the rename?
> > > > >         - does the client do an open by filehandle or an open by name
> > > > >           after the rename?
> > > > >
> > > > > --b.
