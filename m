Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:40106 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab1LHXL5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 18:11:57 -0500
Subject: Re: [RFC][PATCH] libtirpc,rpcbind: move socket from /var/run to /run
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAG-2HqWSnNfUscJ82m8fY9xYm-zAZu2F4b0pj1YPQ2gMGzM+yQ@mail.gmail.com>
Date: Thu, 8 Dec 2011 18:11:45 -0500
Cc: linux-nfs@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>
Message-Id: <C4B82D87-21B3-491A-85C5-FD1927A21337@oracle.com>
References: <1323371940-9140-1-git-send-email-teg@jklm.no> <76A6354E-54A6-4088-9425-B6BB2CE3C92B@oracle.com> <CAG-2HqWSnNfUscJ82m8fY9xYm-zAZu2F4b0pj1YPQ2gMGzM+yQ@mail.gmail.com>
To: Tom Gundersen <teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 8, 2011, at 6:05 PM, Tom Gundersen wrote:

> Hi Chuck,
> 
> On Thu, Dec 8, 2011 at 10:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>> On Dec 8, 2011, at 2:19 PM, Tom Gundersen wrote:
>> 
>>> /run is guaranteed to be available and writeable at any time, whereas
>>> /var might be on a separate partition and hence not available during
>>> early boot. By moving the socket from /var to /run we are able to use
>>> rpcbind earlier, which would in particular make a difference in case
>>> /var is on an nfs mount, something I am currently seeing bug reports
>>> about.
>> 
>> I don't understand this part.  /var should be mounted with "nolock" so there should not be a need to have rpcbind running.  Can you explain what this is about?
> 
> You are right, this particular problem can be written off as a
> configuration error. However, if I understand correctly moving
> /var/run and /var/lock off of /var would eliminate the need to mount
> /var with nolock, and things would "just work", regardless of the
> mount options.

/var/lib/nfs is another reason why you can't do locking on /var.

> Another reason to want the sockets in /run would be the desire to
> start using rpcbind before /var is mounted (even if /var does not
> itself rely on rpcbind). E.g. to start mounting a remote /home while
> the local /var is still being fsck'ed.
> 
>>> This change should not make a difference to software that currently
>>> works as intended, as /var/run should be a symlink or bindmounted
>>> to /run, so anyone relying on the socket being in /var/run will
>>> still find it there.
>> 
>> Even the kernel?
> 
> Good question, it had not occurred to me that the kernel might resolve
> the paths differently than userspace programs. I'll have to look into
> that.
> 
> Thanks for the feedback!
> 
> Tom
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




