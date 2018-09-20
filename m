Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38782 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727680AbeIUAYk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 20 Sep 2018 20:24:40 -0400
Date: Thu, 20 Sep 2018 14:39:50 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180920183950.GA26850@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
 <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org>
 <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <20180918181901.GC1218@fieldses.org>
 <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
 <20180919200214.GB14422@fieldses.org>
 <CAMBWrQkQTzRj5RtqDWRen2YYKzaU_cewTu5UkUMD2Ysmd9wHkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQkQTzRj5RtqDWRen2YYKzaU_cewTu5UkUMD2Ysmd9wHkA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2018 at 11:23:22AM -0700, Stan Hu wrote:
> On Wed, Sep 19, 2018 at 1:02 PM Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Wed, Sep 19, 2018 at 10:39:19AM -0700, Stan Hu wrote:
> > > On Tue, Sep 18, 2018 at 11:19 AM J. Bruce Fields <bfields@fieldses.org> wrote:
> > >
> > > > We know node B has that cat loop that will keep reopening the file.
> > > >
> > > > The only way node B could avoid translating those open syscalls into
> > > > on-the-wire OPENs is if the client holds a delegation.
> > > >
> > > > But it can't hold a delegation on the file that was newly renamed to
> > > > test.txt--delegations are revoked on rename, and it would need to do
> > > > another OPEN after the rename to get a new delegation.  Similarly the
> > > > file that gets renamed over should have its delegation revoked--and we
> > > > can see that the client does return that delegation.  The OPEN here is
> > > > actually part of that delegation return process--the CLAIM_DELEGATE_CUR
> > > > value on "claim type" is telling the server that this is an open that
> > > > the client had cached locally under the delegation it is about to
> > > > return.
> > > >
> > > > Looks like a client bug to me, possibly some sort of race handling the
> > > > delegation return and the new open.
> > > >
> > > > It might help if it were possible to confirm that this is still
> > > > reproduceable on the latest upstream kernel.
> > >
> > > Thanks for that information. I did more testing, and it looks like
> > > this stale file problem only appears to happen when the NFS client
> > > protocol is 4.0 (via the vers=4.0 mount option). 4.1 doesn't appear to
> > > have the problem.
> > >
> > > I've also confirmed this problem happens on the mainline kernel
> > > version (4.19.0-rc4). Do you have any idea why 4.1 would be working
> > > but 4.0 has this bug?
> >
> > No.  I mean, the 4.1/4.0 differences are complicated, so it's not too
> > surprising a bug could hit one and not the other, but I don't have an
> > explanation for this one off the top of my head.
> >
> > > https://s3.amazonaws.com/gitlab-support/nfs/nfs-4.0-kernel-4.19-0-rc4-rename.pcap
> > > is the latest capture that also includes the NFS callbacks. Here's
> > > what I see after the first RENAME from Node A:
> > >
> > > Node B: DELEGRETURN StateId: 0xa93
> > > NFS server: DELEGRETURN
> > > Node A: RENAME From: test2.txt To: test.txt
> > > NFS server: RENAME
> > > Node B: GETATTR
> > > NFS Server: GETATTR (with old inode)
> > > Node B: READ StateId: 0xa93
> > > NFS Server: READ
> >
> > Presumably the GETATTR and READ use a filehandle for the old file (the
> > one that was renamed over)?
> >
> > That's what's weird, and indicates a possible client bug.  It should be
> > doing a new OPEN("test.txt").
> >
> > Also, READ shouldn't be using the stateid that was returned in
> > DELEGRETURN.  And the server should reject any attempt to use that
> > stateid.  I wonder if you misread the stateids--may be worth taking a
> > closer look to see if they're really bit-for-bit identical.  (They're
> > 128 bits, so that 0xa93 is either a hash or just some subset of the
> > stateid.)
> >
> > (Apologies, I haven't gotten a chance to look at it myself.)
> 
> Thanks again for the information.
> 
> It looks like Wireshark is showing the CRC-16 hash of both the
> sequence ID and the other state ID, which makes things a little
> confusing. Here's the abbreviated flow with the 12-byte StateId
> (excludes the sequence number) and hashed values:

Those are 16 bytes, with the last 4 (27/28:00:00:00) the sequence
number:

> Node B: OPEN test.txt
> NFS server: OPEN StateId: 96:49:9c:5b:e0:41:30:32:27:00:00:00 (0x7cd5)
> --- 5 seconds later, presumably when I start the while loop ---
> Node B: READ StateId: 96:49:9c:5b:e0:41:30:32:28:00:00:00 (0xec2c)
> Node B: DELEGRETURN StateId: 96:49:9c:5b:e0:41:30:32:28:00:00:00 (0xce2c)
> NFS server: DELEGRETURN
> Node A: RENAME From: test2.txt To: test.txt
> NFS server: RENAME
> Node B: GETATTR
> NFS Server: GETATTR (with old inode)
> Node B: READ StateId: 96:49:9c:5b:e0:41:30:32:27:00:00:00 (0x7cd5)
> NFS Server: READ
> 
> I'm a bit confused why the READ call would be using a StateId that
> looks like it's one bit off (27 vs 28). It's possible I'm not seeing a
> message in the trace, but is the NFS client doing something behind the
> scenes?
> 
> Note the DELEGRETURN returned the StateId with the 28, and the last
> READ request used 27.

To be honest I'd need a few minutes to refresh my memory of the spec,
but I think this all normal, thanks.

> I repeated the same test using NFS 4.1
> (https://s3.amazonaws.com/gitlab-support/nfs/nfs-4.1-kernel-4.19-0-rc4-rename-test1.pcap).
> The behavior looks quite similar here with the DELEGRETURN and StateId
> values that appear to me as off-by-1. But in this case the NFS client
> requests a new OPEN and READ.
> 
> > I'd assumed that the every open syscall would result in an on-the-wire
> > open or lookup, or at least a getattr to verify of the directory change
> > attribute to verify that the directory hasn't been modified.
> >
> > Trond tells me that's guaranteed only on the first open (of a set of
> > overlapping opens) from that client.  You've already got another open in
> > your test case (if I remember correctly), so you may have to wait for
> > the client's cache of the parent directory to time out (could be a few
> > minutes).  There are some mount options to control this--see the nfs man
> > page.
> 
> Last night I left my test running on for more than 30 minutes, and the
> while loop still showed the stale data. I think I even turned off
> attribute caching entirely to see if this would help, and it did not.

Huh.  Then I'm back to thinking there's a client bug in the 4.0 case.

Thanks for your persistence....

--b.
