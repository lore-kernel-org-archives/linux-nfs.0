Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:38081 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932511Ab1BYQvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Feb 2011 11:51:44 -0500
From: Ferenc Wagner <wferi@niif.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
References: <87wrl6ix2i.fsf@tac.ki.iif.hu> <87mxlpw4cv.fsf@tac.ki.iif.hu>
	<20110222011144.GA18424@fieldses.org> <878vx8huet.fsf@tac.ki.iif.hu>
	<20110223195250.GB13399@fieldses.org> <87r5ax8irr.fsf@tac.ki.iif.hu>
	<20110224173015.GB22070@fieldses.org>
Date: Fri, 25 Feb 2011 17:51:43 +0100
In-Reply-To: <20110224173015.GB22070@fieldses.org> (J. Bruce Fields's message
	of "Thu, 24 Feb 2011 12:30:15 -0500")
Message-ID: <87pqqgqcps.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Thu, Feb 24, 2011 at 06:06:00PM +0100, Ferenc Wagner wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> 
>>> On Tue, Feb 22, 2011 at 06:05:14PM +0100, Ferenc Wagner wrote:
>>>
>>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>>>
>>>>> 	- In the NFSv4.1 case there is a "reclaim complete" rpc that
>>>>> 	  clients are required to send.  Currently we don't take
>>>>> 	  advantage of that to end the grace period early, but we
>>>>> 	  should.  That's no help for 4.0 clients.
>>>> 
>>>> /proc/fs/nfsd/versions shows +4.1 on the server, does this mean that
>>>> nfs4 type Linux client mounts should issue "reclaim complete"?
>>>
>>> It means that a 4.1 is supported, so a client *could* use 4.1 if it
>>> asked to.  And if it did use 4.1, yes, it would be required to issue
>>> reclaim complete.  Current linux clients do not use 4.1 unless you
>>> explicitly ask for it on the mount commandline.
>> 
>> I can't find any mention of 4.1 in man nfs (nfs-common version 1.2.2),
>> is there an undocumented nfsvers=4.1 mount option or some other means?
>
>  -ominorversion=1

Hmm, looks like this feature didn't make it into the squeeze version of
mount.nfs4.  And it's disabled in the kernel, anyway.

>>> (Aside: the server really shouldn't have +4.1 by default, as the 4.1
>>> server is not done.  We should fix that; which distro are you using?)
>> 
>> Debian squeeze.  If it's switchable, then it's possible I switched it
>> on, I can't remember.  However, 4.1 client support is disabled in the
>> stock kernel config, and 4.1 server support isn't even mentioned:
>
> There's no separate config option, but the kernel keeps it off by
> default.  I think nfs-utils is overriding the kernel's default.  We
> should fix that.

At least I can't find any occurence of fs/nfsd/version in my startup and
config scripts.
-- 
Regards,
Feri.
