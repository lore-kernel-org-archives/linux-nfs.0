Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:33846 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751618AbdHKLBw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Aug 2017 07:01:52 -0400
Received: by mail-qt0-f169.google.com with SMTP id s6so19063496qtc.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Aug 2017 04:01:51 -0700 (PDT)
Message-ID: <1502449309.4950.2.camel@redhat.com>
Subject: Re: Do we really need d_weak_revalidate???
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "neilb@suse.com" <neilb@suse.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Fri, 11 Aug 2017 07:01:49 -0400
In-Reply-To: <1502430944.3822.1.camel@primarydata.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name>
         <1502430944.3822.1.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
> > Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
> > flag and introduced the d_weak_revalidate dentry operation instead.
> > We duly removed the flag from NFS superblocks and NFSv4 superblocks,
> > and added the new dentry operation to NFS dentries .... but not to
> > NFSv4
> > dentries.
> > 
> > And nobody noticed.
> > 
> > Until today.
> > 
> > A customer reports a situation where mount(....,MS_REMOUNT,..) on an
> > NFS
> > filesystem hangs because the network has been deconfigured.  This
> > makes
> > perfect sense and I suggested a code change to fix the problem.
> > However when a colleague was trying to reproduce the problem to
> > validate
> > the fix, he couldn't.  Then nor could I.
> > 
> > The problem is trivially reproducible with NFSv3, and not at all with
> > NFSv4.  The reason is the missing d_weak_revalidate.
> > 
> > We could simply add d_weak_revalidate for NFSv4, but given that it
> > has been missing for 4.5 years, and the only time anyone noticed was
> > when the ommission resulted in a better user experience, I do wonder
> > if
> > we need to.  Can we just discard d_weak_revalidate?  What purpose
> > does
> > it serve?  I couldn't find one.
> > 
> > Thanks,
> > NeilBrown
> > 
> > For reference, see
> > Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
> > d_weak_revalidate dentry op")
> > 
> > 
> > 
> > To reproduce the problem at home, on a system that uses systemd:
> > 1/ place (or find) a filesystem image in a file on an NFS filesystem.
> > 2/ mount the nfs filesystem with "noac" - choose v3 or v4
> > 3/ loop-mount the filesystem image read-only somewhere
> > 4/ reboot
> > 
> > If you choose v4, the reboot will succeed, possibly after a 90second
> > timeout.
> > If you choose v3, the reboot will hang indefinitely in systemd-
> > shutdown while
> > remounting the nfs filesystem read-only.
> > 
> > If you don't use "noac" it can still hang, but only if something
> > slows
> > down the reboot enough that attributes have timed out by the time
> > that
> > systemd-shutdown runs.  This happens for our customer.
> > 
> > If the loop-mounted filesystem is not read-only, you get other
> > problems.
> > 
> > We really want systemd to figure out that the loop-mount needs to be
> > unmounted first.  I have ideas concerning that, but it is messy.  But
> > that isn't the only bug here.
> 
> The main purpose of d_weak_revalidate() was to catch the issues that
> arise when someone changes the contents of the current working
> directory or its parent on the server. Since '.' and '..' are treated
> specially in the lookup code, they would not be revalidated without
> special treatment. That leads to issues when looking up files as
> ./<filename> or ../<filename>, since the client won't detect that its
> dcache is stale until it tries to use the cached dentry+inode.
> 
> The one thing that has changed since its introduction is, I believe,
> the ESTALE handling in the VFS layer. That might fix a lot of the
> dcache lookup bugs that were previously handled by d_weak_revalidate().
> I haven't done an audit to figure out if it actually can handle all of
> them.
> 

It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:

    vfs: allow umount to handle mountpoints without revalidating them

Possibly the fact that we no longer try to revalidate during unmount
means that this is no longer necessary?

The original patch that added d_weak_revalidate had a reproducer in the
patch description. Have you verified that that problem is still not
reproducible when you remove d_weak_revalidate?
-- 
Jeff Layton <jlayton@redhat.com>
