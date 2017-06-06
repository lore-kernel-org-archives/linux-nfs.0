Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47568 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751449AbdFFNVY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 09:21:24 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "kernel test robot" <xiaolong.ye@intel.com>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, "Christoph Hellwig" <hch@infradead.org>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0: will-it-scale.per_process_ops
 -14.1% regression
Date: Tue, 06 Jun 2017 09:21:18 -0400
Message-ID: <281BE411-EF62-45F9-85B9-EB4023C99D73@redhat.com>
In-Reply-To: <1496754924.2807.5.camel@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
 <1496317284.2845.4.camel@redhat.com>
 <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
 <1496321961.2845.6.camel@redhat.com> <20170601151415.GA4079@fieldses.org>
 <1496332131.2845.8.camel@redhat.com>
 <E3321EB0-9365-456C-9470-E74291F6FFEA@redhat.com>
 <1496700162.2850.9.camel@redhat.com>
 <3924EE88-DC6E-4D95-9A84-50032930A65C@redhat.com>
 <1496754924.2807.5.camel@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6 Jun 2017, at 9:15, Jeff Layton wrote:

> On Tue, 2017-06-06 at 09:00 -0400, Benjamin Coddington wrote:
>> It would, but I think fl_nspid is completely unnecessary.  The reason we
>> have it so that we can translate the pid number into other namespaces,
>> the
>> most common case being that F_GETLK and views of /proc/locks within a
>> namespace represent the same pid numbers as the processes in that
>> namespace
>> that are holding the locks.
>>
>> It is much simpler to just keep using fl_pid as the pid number in the
>> init
>> namespace, but move the translation of that pid number to lookup time,
>> rather than creation time.
>>
>
> I think that would also work and I like the idea of getting rid of a
> field in file_lock.
>
> So, to be clear:
>
> fl_pid would then store the pid of the process in the init_pid_ns, and
> you'd just translate it as appropriate to the requestor's namespace?

Right!

> If we want to go that route, then you'll probably still need a flag of
> some sort to indicate that the fl_pid is to be expressed "as is", for
> remote filesystems.

Yes, the hack I have now still uses that flag.

> OTOH, if the lock is held remotely, I wonder if we'd be better off
> simply reporting the pid as '-1', like we do with OFD locks. Hardly
> anything pays attention to l_pid anyway and it's more or less
> meaningless once the filesystem extends beyond the machine you're on.
>
> That said, I'd be inclined to do that in a separate set so we could
> revert it if it caused problems somewhere.

I think keeping that change separate is a good idea.  It might be a good
idea to just stay away from that change unless there's a compelling reason
for it.  If l_sysid ever happens, then there's no need to change the
behavior for l_pid back again.

I'll send some patches in a bit when I am happy with them.

Ben
