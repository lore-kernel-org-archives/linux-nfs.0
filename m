Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:50818 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268Ab0AWQ1k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jan 2010 11:27:40 -0500
Received: by ewy26 with SMTP id 26so437585ewy.28
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2010 08:27:39 -0800 (PST)
In-Reply-To: <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com>
References: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com>
	 <1f808b4a1001230757i2027d32dxb48482ea7bf8e4ee@mail.gmail.com>
Date: Sat, 23 Jan 2010 17:27:38 +0100
Message-ID: <d7f0b3a81001230827y52727993nf60210ae610643b7@mail.gmail.com>
Subject: Re: nfs client performance while server is down
From: Whoop Whouzer <tiredandnumb@gmail.com>
To: Peter Chacko <peterchacko35@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I don't remember all the different set-ups I tried it on, but I just
confirmed this with the following combinations:

ubuntu server 10.04 (alpha 2) --> ubuntu desktop 9.10, ubuntu desktop
10.04 (alpha 2), fedora 12
ubuntu server 9.10 --> ubuntu desktop 9.10, ubuntu desktop 10.04
(alpha 2), fedora 12

I'll be happy to test it on another client machine (distro) even
another server (although it would require a little more time)

Here are some examples on the bugreports I noticed and how they do not
seem to get solved:
https://bugzilla.redhat.com/show_bug.cgi?id=175283
https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/164120

regards,
Whoop

On Sat, Jan 23, 2010 at 4:57 PM, Peter Chacko <peterchacko35@gmail.com> wrote:
> Which client OS you observed this behavior ?  This has nothing to do
> NFS design, and its purely stateless...Its upto the client OS
> implementation about aspects like how to deal with local IO, when NFS
> share gets  disconnected..
>
> May be a VFS bug on the local OS you found this problem ..
>
> thanks
>
> On Sat, Jan 23, 2010 at 9:15 PM, Whoop Whouzer <tiredandnumb@gmail.com> wrote:
>> Howdy,
>>
>> I was wondering why nfs is designed in such a way that the performance
>> of an nfs client machine gets very bad when the nfs server is offline?
>> This is even the case with a soft mount (either via mount or fstab).
>> Just about every application that requires disk access (not talking
>> about nfs share acces) gets really slow to unresponsive. For instance
>> nautilus becomes unresponsive when displaying the contents of any
>> folder on the local disk,
>> playing movie files (stored on local disk) let totem or vlc get stuck
>> on set intervals, even the terminal becomes unresponsive at times.
>>
>> I could understand that these problems would occur while accessing the
>> nfs share directoiourry while the server is offline, but why for totally
>> unrelated directories?
>>
>> I have experienced this behaviour on various distro's, and also found
>> various bug reports on this issue, they don't seem to get solved as
>> this is viewed as nfs design.
>> I see this as a flaw because clients are totally dependent on the
>> server. This would be less of a deal if the entire home directory
>> would be stored on nfs (although I even think some sort of
>> synchronisation technology could and should be implemented in this
>> case). It is a bit odd that (technically) one machine serving some
>> "useless" files to a non-trivial directory on client machines can take
>> down these client machines.
>>
>> For me the preferred functionality would be:
>> *If an nfs server gets offline the client's nfs share becomes
>> unaccessible, but local directories and applications (that only
>> require local disk access) stay responsive.
>> *If an nfs server gets online (after being offline while the client
>> has not been restarted) the nfs share becomes reconnected.
>>
>> regards,
>> Whoop
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
