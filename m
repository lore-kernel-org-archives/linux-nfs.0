Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f45.google.com ([209.85.160.45]:51808 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab3BBG3h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2013 01:29:37 -0500
Received: by mail-pb0-f45.google.com with SMTP id rq13so2457799pbb.32
        for <linux-nfs@vger.kernel.org>; Fri, 01 Feb 2013 22:29:36 -0800 (PST)
Message-ID: <510CB210.6010804@gmail.com>
Date: Sat, 02 Feb 2013 11:58:32 +0530
From: "dE ." <de.techno@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 cannot unmount ESTALE directories (in some cases).
References: <20130121134859.24fbd103@notabene.brown> <20130121030940.GS4939@ZenIV.linux.org.uk>
In-Reply-To: <20130121030940.GS4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/21/13 08:39, Al Viro wrote:
> On Mon, Jan 21, 2013 at 01:48:59PM +1100, NeilBrown wrote:
>> If you use NFSv4 to "mount server:/foo/bar /mnt", then "rm -r" /foo/bar on the
>> server, then accesses to /mnt will naturally return ESTALE.
>>
>> Unfortunately "umount /mnt" will also return ESTALE and leave the stale
>> directory mounted.  Adding "-l" or "-f" to "umount" doesn't help.
>>
>> The problem is that nfs_lookup_revalidate fails.  As the mountpoint is never
>> not accessed by a lookup (after the initial mount) it seems a bit pointless
>> calling d_revalidate in this case ... by maybe not.
>>
>> I can make the problem go away by testing for LOOKUP_JUMP and having
>> nfs_lookup_revalidate never fail if that flag it set (for a directory).
>> However I cannot easily tell if this is an elegant solution of an ugly hack,
> The latter.  Definitely.
>
>> and am hoping that someone who understands revalidation and LOOKUP_JUMPED
>> better than I (who only discovered the latter today) could provide advice.
>>
>> Al?  Trond?  Should  I make this into a formal patch submission, or is there
>> a better way?
> I really suspect that mountpoint crossing on umount ought to be done
> differently.  I'll need to play with possible variants a bit before I can
> offer any replacement though...
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I'm affected. I've to do exportfs -f to fix the issue. This problem only 
persists with loop mounts.
