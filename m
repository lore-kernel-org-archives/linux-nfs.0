Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48684 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726463AbeIZCni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Sep 2018 22:43:38 -0400
Date: Tue, 25 Sep 2018 16:34:18 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Stan Hu <stanhu@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180925203418.GB9559@fieldses.org>
References: <20180917220107.GB21269@fieldses.org>
 <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <20180918181901.GC1218@fieldses.org>
 <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
 <20180919200214.GB14422@fieldses.org>
 <CAMBWrQkQTzRj5RtqDWRen2YYKzaU_cewTu5UkUMD2Ysmd9wHkA@mail.gmail.com>
 <20180920183950.GA26850@fieldses.org>
 <CAMBWrQmUwmFenuxhs_jYX90R8ZgQ7+8QbWm=FpJrp7yxEwNFCw@mail.gmail.com>
 <CAMBWrQnKgmN83wmo35pVh26psEQagk0EWEm8KRJwutzmtmwcqg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMBWrQnKgmN83wmo35pVh26psEQagk0EWEm8KRJwutzmtmwcqg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 25, 2018 at 11:56:16AM -0700, Stan Hu wrote:
> >From https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/5.6_technical_notes/known_issues-kernel,
> I see this bug has been known for a while:

That specific server bug was fixed in several years ago, and I forget
what kernel version you were using on the server, but I'm pretty sure it
has the fix.  From the network trace it looks like delegations were
being returned when they should be.

--b.

> 
> In some cases the NFS server fails to notify NFSv4 clients about
> renames and unlinks done by other clients, or by non-NFS users of the
> server. An application on a client may then be able to open the file
> at its old pathname (and read old cached data from it, and perform
> read locks on it), long after the file no longer exists at that
> pathname on the server.
> 
> To work around this issue, use NFSv3 instead of NFSv4. Alternatively,
> turn off support for leases by writing 0 to /proc/sys/fs/leases-enable
> (ideally on boot, before the nfs server is started). This change
> prevents NFSv4 delegations from being given out, restore correctness
> at the expense of some performance.
> 
> On Mon, Sep 24, 2018 at 1:34 PM Stan Hu <stanhu@gmail.com> wrote:
> >
> > On Thu, Sep 20, 2018 at 11:39 AM Bruce Fields <bfields@fieldses.org> wrote:
> >
> > > > Last night I left my test running on for more than 30 minutes, and the
> > > > while loop still showed the stale data. I think I even turned off
> > > > attribute caching entirely to see if this would help, and it did not.
> > >
> > > Huh.  Then I'm back to thinking there's a client bug in the 4.0 case.
> > >
> >
> > I've been doing more digging, and I think there is some issue with the
> > cache validation here. In NFS 4.1, it looks like in dir.c
> > nfs4_lookup_revalidate() calls nfs_lookup_revalidate() since the
> > NFS_CAP_ATOMIC_OPEN_V1 flag is active
> > (https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1591).
> > On the other hand, since that flag isn't active for NFS 4.0, the
> > validation is much briefer
> > (https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1599-L1628).
> >
> > I'm not sure if the comment in
> > https://github.com/torvalds/linux/blob/v4.19-rc4/fs/nfs/dir.c#L1630
> > actually reflects what's happening. If I look at the stack trace of
> > the next file open call, I don't see additional validation:
> >
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233460] Call Trace:
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233462]  dump_stack+0x8e/0xd5
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233480]
> > nfs4_file_open+0x56/0x2a0 [nfsv4]
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233488]  ?
> > nfs42_clone_file_range+0x1c0/0x1c0 [nfsv4]
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233490]  do_dentry_open+0x1f6/0x360
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233492]  vfs_open+0x2f/0x40
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233493]  path_openat+0x2e8/0x1690
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233496]  ?
> > mem_cgroup_try_charge+0x8b/0x190
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233497]  do_filp_open+0x9b/0x110
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233499]  ?
> > __check_object_size+0xb8/0x1b0
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233501]  ? __alloc_fd+0x46/0x170
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233503]  do_sys_open+0x1ba/0x250
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233505]  ? do_sys_open+0x1ba/0x250
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233507]  __x64_sys_openat+0x20/0x30
> > Sep 24 20:20:38 test-kernel kernel: [ 1145.233508]  do_syscall_64+0x65/0x130
> >
> > If I naively apply this patch:
> >
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 8bfaa658b2c1..6e3ece2e6984 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -1631,7 +1631,7 @@ static int nfs4_lookup_revalidate(struct dentry
> > *dentry, unsigned int flags)
> >         ret = 1;
> >
> >  out:
> > -       return ret;
> > +       return nfs_lookup_revalidate(dentry, flags);
> >
> >  no_open:
> >         return nfs_lookup_revalidate(dentry, flags);
> >
> > Things behave as expected on NFS 4.0. What's the right fix here?
