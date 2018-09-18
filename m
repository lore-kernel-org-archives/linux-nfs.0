Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34218 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729851AbeISAHH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Sep 2018 20:07:07 -0400
Date: Tue, 18 Sep 2018 14:33:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180918183315.GD1218@fieldses.org>
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org>
 <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org>
 <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <CAMBWrQn35GoMSXCZiEjKW1hxz96ujPDjjooV=y_yLBR_BYU+fg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQn35GoMSXCZiEjKW1hxz96ujPDjjooV=y_yLBR_BYU+fg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 18, 2018 at 10:42:03AM -0700, Stan Hu wrote:
> Here are more traces that have been pared down by introducing a
> 10-second sleep in the while loop:
> 
> 1. Experiment 1: A normal rename from test2.txt to test.txt without a
> file open: https://s3.amazonaws.com/gitlab-support/nfs/exp1-normal-rename-over-nfs.pcap
> 2. Experiment 2: A rename from test2.txt to test.txt with a file open:
> https://s3.amazonaws.com/gitlab-support/nfs/exp2-rename-over-nfs-with-file-open.pcap
> 3. Experiment 3: Same as experiment 2 except an `ls` was issued in the
> directory where the files reside:
> https://s3.amazonaws.com/gitlab-support/nfs/exp3-rename-over-nfs-with-file-open-and-ls.pcap
> 
> In the pcap of experiment 2, as before we see the NFS respond to the
> first RENAME request with a NFS4ERR_DELAY.
> 
> The next RENAME succeeds, and it looks to me that the GETATTR call for
> the file handle receives a modification time of 3 minutes prior to the
> current timestamp.

In this case (rename within a directory, over an existing file), there
are three objects affected: the file that's being renamed, the file
that's renamed over, and the parent directory.

Neither file should see it's mtime change: mtime only changes when a
file's data changes.

The ctime changes whenever datat or attributes change.  I'm not sure
whether the ctime of the renamed file is expected to change.  The ctime
of the renamed-over file will change (if for no other reason that that
it's nlink value changes from 1 to 0).

The directory mtime and ctime will both change, I think.

In any case, what the client actually relies on here is that the rename
changes the NFSv4 attribute called "Change".  Depending on filesystem
and kernel version that "Change" attribute may be derived from the ctime
or from a separate counter.  In any case, if that's not changing,
there's a problem.  I bet it is changing, though, so I doubt that's the
bug here.

> I could see how this might make sense since there
> is an open file handle out there for this file.
> Is this behavior up to the server implementation, and the Linux
> implementation chooses to allow references to old handles?  I see in
> https://tools.ietf.org/html/rfc3010#page-153:
> 
> A filehandle may or may not become stale or expire on a rename.
> However, server implementors are strongly encouraged to attempt to
> keep file handles from becoming stale or expiring in this fashion.
> 
> In experiment 3, I see a burst of activity after the "ls" call. In
> both experiments 1 and 3, I see more than 1 OPEN request for test.txt,
> which seems to refresh the inode of test.txt.
> 
> Any idea what's going on here?

The filehandle of the renamed file should definitely stay good after the
rename.  The filehandle of the file that was renamed over (the old
"test.txt") might or might not.  I know the Linux server will still keep
it around as long as an NFSv4 client has it opened and there's not a
server reboot.  Your isilon server might start returning STALE as soon
as its unlinked by the rename, and that's probably an OK implementation
choice.

--b.
