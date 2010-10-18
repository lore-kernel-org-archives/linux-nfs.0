Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og110.obsmtp.com ([64.18.0.20]:39354 "HELO
	exprod5og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753807Ab0JRRON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 13:14:13 -0400
Message-ID: <4CBC805B.60909@panasas.com>
Date: Mon, 18 Oct 2010 19:14:03 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jesper Krogh <jesper@krogh.cc>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: lsof and open files from the nfs-server
References: <4CB62095.4010708@krogh.cc> <4CBC74E8.7070801@panasas.com> <20101018170459.GA3744@fieldses.org>
In-Reply-To: <20101018170459.GA3744@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 10/18/2010 07:04 PM, J. Bruce Fields wrote:
> On Mon, Oct 18, 2010 at 06:25:12PM +0200, Boaz Harrosh wrote:
>> On 10/13/2010 11:11 PM, Jesper Krogh wrote:
>>> Hi.
>>>
>>> Quite often when you have to umount a fileshare you get the
>>> message "Device or resource busy". Typically I traverse through
>>> the output of lsof | grep mountpoint and stop processes or kill
>>> until I can safely umount.
>>>
>>> But the nfs-kernel-server does not register its open files, so
>>> seen from userspace is it extremely hard to find out that is actually
>>> is the nfs-server that prevents you from being able to umount
>>> the filesystems.
>>>
>>> Would it be possible to register the open files the same place
>>> so administrators can see them?
>>>
>>> ... basically just a feature-request from one who just spend an hour on 
>>> that.
>>>
>>
>> Me to!
>>
>> Also note that even if there are no open files in clients
>> and no client mounts on the server, but there where in the
>> passed. The used to be used super-block is referenced. Only
>> restart of the nfs service will release it.
>>
>> But yes if it could register as a special file for lsof to
>> see it would help a lot.
> 
> So what does lsof do, scan /proc/?  Does it make sense to have proc
> entries for kernel threads?  Is there any other subsystem that does this
> kind of thing?
> 

Don't mind if I do ;-)

I don't know about policy here and what it actually means (Lifetime rules,
module dependency, ...) But it would be nice to have it, as a user.

If it can not be added to the regular /proc places. Maybe we can patch
lsof to also look in nfs special places and print those as well.

> --b.

Thanks
Boaz
