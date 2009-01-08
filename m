From: Felix Bolte <gockelhahn@hotmail.com>
Subject: RE: exporting loop devices / fsid issue
Date: Thu, 8 Jan 2009 17:52:52 +0100
Message-ID: <BLU106-W41CBED673D264FC30BE28AC9DC0@phx.gbl>
References: <BLU106-W57D668101BC034E6586C60C9DF0@phx.gbl>
 <20090107205419.GH30538@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blu0-omc3-s28.blu0.hotmail.com ([65.55.116.103]:63431 "EHLO
	blu0-omc3-s28.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752003AbZAHQwx convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 11:52:53 -0500
In-Reply-To: <20090107205419.GH30538@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


hi bruce,


>> But it doesn't work on newer kernels. I don't know why,
but the fsid changed to something random, which is not worse, but for
both exports we have now the same fsid.
>> Same fsid + same
inode number == same filehandle. Although i mounted the two directories
separately, i can only change the first one, because the seconds maps
to the first too.
>>
>> Ubuntu 8.04 (kernel 2.6.24):
>> fsid: 0xf4fc911be355fa99
>> fsid: 0xf4fc911be355fa99
>> OpenSuse 11.1 (kernel 2.6.27):
>> fsid: 0xf4fc911be355fa99
>> fsid: 0xf4fc911be355fa99
>
> That's an amusing example! (Why are you doing this?)


well, why i am doing this ...



i want to export cow (copy on write) devices ... i have an image, which is read only

and on top of that i want to create multiple (read / write) devices,

which should only save the differences referring to the base image



/dev/mapper/base (read only):


- /dev/mapper/cow1 (read / write)

- /dev/mapper/cow2 (read / write)



i want to export both cow devices, which were created by linux device-mapper ...



> Anyway, yes, the composition of the filehandle did change, and it's now
> calculated from the contents of the filesystem itself using libblkid.

what was the old behaviour or library, which calculated the fsid from the major/minor device number?
can i switch back?

btw: why was it changed?


> That's usually the right thing to do, but you've found a case where it's
> not! So, i think the solution is to make sure the fsid= option works
> right:

that would be great, allthough i don't want to export each cow device as a single export ...
i want want to export one directory where all cow devices are mounted inside - 
should be possible with the "crossmnt" option ...



>> Ok, this point wasn't clear to me. Could be that the fsid
naming was changed. I found out there's an option to manually set an
fsid to my exports. /etc/exports now looks like:
>>
>> /export/1 *(fsid=10,rw,no_root_squash,no_subtree_check)
>> /export/2 *(fsid=11,rw,no_root_squash,no_subtree_check)
>>
>
> I mounted them again on the client machine. There is still the
same problem, they have the same content. If I rename a file in /mnt/2,
it is also renamed in /mnt/1.
>>
>> Again sniffing
the network packets. The fsid of the first export was
0x0000000000000000a (which is 10 in decimal) as it should be, but the
fsid on the second one was also 0x0a instead of 0x0b (decimal 11).
>
> You're looking at the filehandle there, right?

no, here i'm looking at the fsid ... 
when i mount the second export, i see the same fsid in the traffic


> Anyway, that's odd. Actually, I expected it to ignore the fsid= option
> entirely; I thought that was the current kernel behavior was (and steved
> had a patch to change that).

in my case the "fsid" option wasn't ignored ... but the second export did get the wrong one



best regards

felix bolte

_________________________________________________________________
http://redirect.gimas.net/?n=M0901xMMe
Minimize-Me: Gestalte dein eigenes Messenger Anzeigenbild!