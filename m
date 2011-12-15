Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:62739 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab1LOTO3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 14:14:29 -0500
Message-ID: <4EEA469E.6070307@oracle.com>
Date: Thu, 15 Dec 2011 11:12:30 -0800
From: Maxim Uvarov <maxim.uvarov@oracle.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: linux-nfs@vger.kernel.org, bfields@fieldses.org,
        Trond.Myklebust@netapp.com, john@johnmccutchan.com, rlove@rlove.org,
        eparis@parisplace.org
Subject: Re: [PATCH] NFS/INOTIFY: inotify user when deleting files on nfs
References: <1323903495-4084-1-git-send-email-maxim.uvarov@oracle.com> <1323903495-4084-2-git-send-email-maxim.uvarov@oracle.com> <20111214232254.GP2203@ZenIV.linux.org.uk>
In-Reply-To: <20111214232254.GP2203@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/14/2011 03:22 PM, Al Viro wrote:
> On Wed, Dec 14, 2011 at 02:58:15PM -0800, Maxim Uvarov wrote:
>> This issue was introduced with LTP inotify02 test.
>> If file system is not NFS user inotify application
>> gets IN_DELETE event. But on NFS code avoids d_delete()
>> which sends this event. This patch makes notification
>> on NFS the same as non-NFS. I.e. vfs_unlink still avoids
>> deletion but it sends event for NFS sillyrenamed files.
>> More details here:
>> https://lkml.org/lkml/2011/11/29/421
>
> NAK.  Too damn ugly.  And completely misses the point of inotify -
> seeing events generated only by this client is going to be worthless.
> Face it, inotify is broken by design for network filesystems.  Any
> software using it on NFS is broken; trying to paper over that is
> not a good idea.
>
> Just.  Don't.  Use.  That.  Shit.

Thank you for so technical answer. It's really difficult to object 
against such considered and well-grounded, forcible arguments.

Now to be serious:

1. Original VFS code already has "if NFS", in vfs_unlink(). Because of 
code does not call d_delete() it has to call notification from d_delete().

2. inotify is done on VFS layer. So logically it has to work on all file 
systems.

3. We think that software works if it's execution matches specification. 
Because we don't have any specification for inotify we can relay on 
tests. I.e. if all test for all notification events passed the same way 
for all file systems; events, number of events and sequence for events 
matches and do not depend on file system type - we can say that this 
feature works. As the base for inotify we can take LTP tests, which have 
good coverage for all events.


Best regards,
Maxim Uvarov.
