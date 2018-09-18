Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35807 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729037AbeIRXPz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2018 19:15:55 -0400
Received: by mail-it0-f66.google.com with SMTP id 139-v6so4148202itf.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2018 10:42:16 -0700 (PDT)
MIME-Version: 1.0
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org> <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org> <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
In-Reply-To: <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
From: Stan Hu <stanhu@gmail.com>
Date: Tue, 18 Sep 2018 10:42:03 -0700
Message-ID: <CAMBWrQn35GoMSXCZiEjKW1hxz96ujPDjjooV=y_yLBR_BYU+fg@mail.gmail.com>
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are more traces that have been pared down by introducing a
10-second sleep in the while loop:

1. Experiment 1: A normal rename from test2.txt to test.txt without a
file open: https://s3.amazonaws.com/gitlab-support/nfs/exp1-normal-rename-over-nfs.pcap
2. Experiment 2: A rename from test2.txt to test.txt with a file open:
https://s3.amazonaws.com/gitlab-support/nfs/exp2-rename-over-nfs-with-file-open.pcap
3. Experiment 3: Same as experiment 2 except an `ls` was issued in the
directory where the files reside:
https://s3.amazonaws.com/gitlab-support/nfs/exp3-rename-over-nfs-with-file-open-and-ls.pcap

In the pcap of experiment 2, as before we see the NFS respond to the
first RENAME request with a NFS4ERR_DELAY.

The next RENAME succeeds, and it looks to me that the GETATTR call for
the file handle receives a modification time of 3 minutes prior to the
current timestamp. I could see how this might make sense since there
is an open file handle out there for this file.
Is this behavior up to the server implementation, and the Linux
implementation chooses to allow references to old handles?  I see in
https://tools.ietf.org/html/rfc3010#page-153:

A filehandle may or may not become stale or expire on a rename.
However, server implementors are strongly encouraged to attempt to
keep file handles from becoming stale or expiring in this fashion.

In experiment 3, I see a burst of activity after the "ls" call. In
both experiments 1 and 3, I see more than 1 OPEN request for test.txt,
which seems to refresh the inode of test.txt.

Any idea what's going on here?
On Mon, Sep 17, 2018 at 3:48 PM Stan Hu <stanhu@gmail.com> wrote:
>
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
