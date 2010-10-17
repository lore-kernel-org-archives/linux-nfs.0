Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:54634 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932530Ab0JQTHx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 17 Oct 2010 15:07:53 -0400
Received: by qyk2 with SMTP id 2so205847qyk.19
        for <linux-nfs@vger.kernel.org>; Sun, 17 Oct 2010 12:07:52 -0700 (PDT)
In-Reply-To: <1287336241.5266.19.camel@heimdal.trondhjem.org>
References: <AANLkTikOjYEBGJVHc7fKisNoC7OrJRjePuCcaNtPnHCy@mail.gmail.com>
	<1287336241.5266.19.camel@heimdal.trondhjem.org>
Date: Sun, 17 Oct 2010 23:07:52 +0400
Message-ID: <AANLkTimsEoWmm8dZSTT2HA1vhc1wfJK6QpqHA0q9Yt8r@mail.gmail.com>
Subject: Re: Strange behaviour of NFS4ERR_MOVED and referrals
From: Pavel Strashkin <pavel.strashkin@nexenta.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I knew that you will first who will answer on my question :) Thank you
for your explanation.

Do you have any plans (or may be progress) for migration mechanism? I
mean the situations when on a server side a referral object will store
the new fs_locations list or will be replaced by a real directory, and
the client automatically will do re-mount.

2010/10/17 Trond Myklebust <trond.myklebust@fys.uio.no>:
> On Sun, 2010-10-17 at 15:51 +0400, Pavel Strashkin wrote:
>> Hi all,
>>
>> I'm learning NFS4 "referral" feature.
>> I have 4 machines with installed Ubuntu 10.10 (kernel
>> 2.6.35-22-generic): Server-A, Server-B, Server-C and Client-A.
>>
>> Server-A is the main server in the "cluster" that provides NFS share
>> "/exports" with a single referral: "/exports/referral".
>> That referral points to 2 servers: Server-B and Server-C.
>>
>> Client-A is the user of this referral.
>>
>> When i mount "/exports" NFS share from Server-A on Client-A, i have no
>> issues and i can see "referral" directory. After that Client-A have an
>> access to that "referral" directory and can see files on Server-B
>> because Server-B the first server in referral list. NFS4ERR_MOVED
>> works as expected.
>>
>> ...now let's switch off Server-B...
>>
>> When Server-B is down (dont forget, we had 2 servers in referral list)
>> and i'm trying to do "ls -l" for "referral" directory, the operation
>> hangs forever. If i kill -9 "ls" process and remount directory then it
>> automatically switches to Server-C (because Server-B is unreachabel).
>>
>> The question: why there is no migration (fail-over? switch?) to
>> another server from referral list when share already mounted and
>> current server from referral list is down?
>>
>> I looked at NFS kernel code and as i understand it keeps information
>> about FIRST valid server from referral list in inode. It keeps single
>> server information, not a whole list of servers (fs_locations). After
>> that all operations related to referral inode will be delegated to
>> that server.
>>
>> RFC says that if client can not access to the first server in referral
>> list, it should try the next. One thing i dont undertand here - RFC
>> means "try next" when we do mount or when we're working with referral
>> inode?
>>
>> P.S. i also triend another one situation: i removed referral on
>> Server-A and replace it by real directory called "referral". After
>> that client still trying to access to referral (share on Server-B),
>> but not real directory on Server-A. Seems like invalidation does not
>> work.
>
> Please don't confuse referrals and migrations; they are very different
> events.
>
>        A referral is special type of filesystem object that is
>        discovered at LOOKUP time, and basically acts to automount a new
>        filesystem from a different server. This is an easy case to
>        implement, because you are mounting a new filesystem, and so
>        there is no existing file state to worry about.
>
>        A migration is an event that occurs after the client has mounted
>        a filesystem. It means that particular filesystem has been
>        removed from the original server, and should now be mounted
>        through a different server. This is a very difficult case to
>        implement because the NFS protocol does not specify how the
>        migration should occur on the back end (i.e. from server to
>        server). The client therefore may end up having to do a lot of
>        extra work in order to recover filehandles, file open and
>        locking state, without the application discovering what is going
>        on.
>
> The Linux client supports referrals. It does not yet support migration.
>
> Trond
>
>
