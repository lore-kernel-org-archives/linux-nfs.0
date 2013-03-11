Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:61815 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3CKOAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Mar 2013 10:00:00 -0400
MIME-Version: 1.0
In-Reply-To: <51364285.4040406@samba.org>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru>
	<512FD1D5.3010106@mit.edu>
	<20130304211923.GI20389@fieldses.org>
	<5135250A.30604@samba.org>
	<20130305181306.GA15816@fieldses.org>
	<51364285.4040406@samba.org>
Date: Mon, 11 Mar 2013 17:59:59 +0400
Message-ID: <CAKywueR8kFUS46pCOnEaTouavTu69gW_FmP5BtFS2rsX8nHtBw@mail.gmail.com>
Subject: Re: [PATCH v3 0/7] Add O_DENY* support for VFS and CIFS/NFS
From: Pavel Shilovsky <piastry@etersoft.ru>
To: Simo <simo@samba.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, wine-devel@winehq.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2013/3/5 Simo <simo@samba.org>:
> On 03/05/2013 01:13 PM, J. Bruce Fields wrote:
>>
>> On Mon, Mar 04, 2013 at 05:49:46PM -0500, Simo wrote:
>>>
>>> On 03/04/2013 04:19 PM, J. Bruce Fields wrote:
>>>> I'm a little more worried: these are mandatory locks, and applications
>>>> that use them are used to the locks being enforced correctly.  Are we
>>>> sure that an application that opens a file O_DENYWRITE won't crash if it
>>>> sees the file data change while it holds the open?
>>>
>>> The redirector may simply assume it has full control of that part of
>>> the file and not read nor send data until the lock is released too,
>>> so you get conflicting views of the file contents between different
>>> clients if you let a mandatory lock not be mandatory.
>>>
>>>> In general the idea of making a mandatory lock opt-in makes me nervous.
>>>> I'd prefer something like a mount option, so that we know that everyone
>>>> on that one filesystem is playing by the same rules, but we can still
>>>> mount filesystems like / without the option.
>>>
>>> +1
>>>
>>>> But I'll admit I'm definitely not an expert on Windows locking and may
>>>> be missing something about how these locks are meant to work.
>>>
>>> Mandatory locks really are mandatory in Windows.
>>> That may not be nice to a Unix system but what can you do ?
>>
>> I wonder if we could repurpose the existing -omand mount option?
>>
>> That would be a problem for anyone that wants to allow mandatory fcntl
>> locks without allowing share locks.  I doubt anyone sane actually uses
>> mandatory fcntl locks, but still I suppose it would probably be better
>> to play it safe and use a new mount option.
>
>
> Maybe we should have a -o win_semantics option :-)
>
> /me runs
>

(CC'ing Al Viro, since these patches should go through his tree)

I don't mind to introduce a new mount option for turning this feature
on/off - something like '-o denylock' to make it mathing names of new
flags would be ok.

Al, what do you think about this feature overall?

-- 
Best regards,
Pavel Shilovsky.
