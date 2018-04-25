Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from uhil19pa10.eemsg.mail.mil ([214.24.21.83]:7000 "EHLO
        uhil19pa10.eemsg.mail.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754131AbeDYOPo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Apr 2018 10:15:44 -0400
Subject: Re: [PATCH 04/24] VFS: Add LSM hooks for filesystem context [ver #7]
To: David Howells <dhowells@redhat.com>
Cc: Paul Moore <paul@paul-moore.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org, viro@zeniv.linux.org.uk,
        selinux@tycho.nsa.gov, linux-fsdevel@vger.kernel.org,
        linux-afs@lists.infradead.org
References: <aca7e68c-022b-47ac-c249-59e042d431e8@tycho.nsa.gov>
 <CAHC9VhQhaBNBFwAXJ4TxKO56UTcwb_LcT2G8LwNxdxOD96tTvA@mail.gmail.com>
 <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
 <152414469006.23902.8132059438921850399.stgit@warthog.procyon.org.uk>
 <3232.1524238511@warthog.procyon.org.uk>
 <703.1524583367@warthog.procyon.org.uk>
From: Stephen Smalley <sds@tycho.nsa.gov>
Message-ID: <1bb08eac-517a-a07e-5e64-5771cc0c0afc@tycho.nsa.gov>
Date: Wed, 25 Apr 2018 10:07:15 -0400
MIME-Version: 1.0
In-Reply-To: <703.1524583367@warthog.procyon.org.uk>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/24/2018 11:22 AM, David Howells wrote:
> Stephen Smalley <sds@tycho.nsa.gov> wrote:
> 
>> Neither fsopen() nor fscontext_fs_write() appear to perform any kind of
>> up-front permission checking (DAC or MAC), although some security hooks may
>> be ultimately called to allocate structures, parse security options, etc.
>> Is there a reason not apply a may_mount() or similar check up front?
> 
> may_mount() is called by fsmount() at the moment.  It may make sense to move
> this earlier to fsopen().  Note that there's also going to be something that
> looks like:
> 
> 	fd = fspick("/mnt");
> 	fsmount(fd, "/a", MNT_NOEXEC); // ie. bind mount
> 
> or:
> 
> 	fd = fspick("/mnt");
> 	write(fd, "o intr");
> 	write(fd, "x reconfigure"); // ie. something like remount
> 	close(fd);
> 
> I guess we'd want to call may_mount() in fspick() too.  But there's also the
> possibility of using this to create a query interfact too:
> 
> 	fd = fspick("/mnt");
> 	write(fd, "q intr");
> 	read(fd, value_buffer);

My concern was that fsopen()/fscontext_fs_write() may expose attack surface (e.g. mount option parsing code) that might not be normally accessible to unprivileged userspace (i.e. gated by may_mount() and security_sb_mount()) prior to your changes.


