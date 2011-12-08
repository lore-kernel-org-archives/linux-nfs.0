Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bw0-f46.google.com ([209.85.214.46]:56261 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab1LHXFe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 18:05:34 -0500
Received: by bkbzv3 with SMTP id zv3so2220256bkb.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2011 15:05:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <76A6354E-54A6-4088-9425-B6BB2CE3C92B@oracle.com>
References: <1323371940-9140-1-git-send-email-teg@jklm.no> <76A6354E-54A6-4088-9425-B6BB2CE3C92B@oracle.com>
From: Tom Gundersen <teg@jklm.no>
Date: Fri, 9 Dec 2011 00:05:12 +0100
Message-ID: <CAG-2HqWSnNfUscJ82m8fY9xYm-zAZu2F4b0pj1YPQ2gMGzM+yQ@mail.gmail.com>
Subject: Re: [RFC][PATCH] libtirpc,rpcbind: move socket from /var/run to /run
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, Kay Sievers <kay.sievers@vrfy.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

On Thu, Dec 8, 2011 at 10:40 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Dec 8, 2011, at 2:19 PM, Tom Gundersen wrote:
>
>> /run is guaranteed to be available and writeable at any time, whereas
>> /var might be on a separate partition and hence not available during
>> early boot. By moving the socket from /var to /run we are able to use
>> rpcbind earlier, which would in particular make a difference in case
>> /var is on an nfs mount, something I am currently seeing bug reports
>> about.
>
> I don't understand this part.  /var should be mounted with "nolock" so there should not be a need to have rpcbind running.  Can you explain what this is about?

You are right, this particular problem can be written off as a
configuration error. However, if I understand correctly moving
/var/run and /var/lock off of /var would eliminate the need to mount
/var with nolock, and things would "just work", regardless of the
mount options.

Another reason to want the sockets in /run would be the desire to
start using rpcbind before /var is mounted (even if /var does not
itself rely on rpcbind). E.g. to start mounting a remote /home while
the local /var is still being fsck'ed.

>> This change should not make a difference to software that currently
>> works as intended, as /var/run should be a symlink or bindmounted
>> to /run, so anyone relying on the socket being in /var/run will
>> still find it there.
>
> Even the kernel?

Good question, it had not occurred to me that the kernel might resolve
the paths differently than userspace programs. I'll have to look into
that.

Thanks for the feedback!

Tom
