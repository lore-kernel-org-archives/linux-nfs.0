From: Roger Marcus <roger.marcus@gmail.com>
Subject: Re: Problem with NFS and XEN
Date: Fri, 8 May 2009 16:32:18 +0200
Message-ID: <c4838b6b0905080732v7f693436md49bc6dcdca5d6d9@mail.gmail.com>
References: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com>
	 <1241785441.19651.28.camel@heimdal.trondhjem.org>
	 <c4838b6b0905080611n3ef3f2efr3e843836b1e3dd@mail.gmail.com>
	 <1241790224.19651.40.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:59466 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbZEHOcU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 10:32:20 -0400
Received: by bwz22 with SMTP id 22so1405078bwz.37
        for <linux-nfs@vger.kernel.org>; Fri, 08 May 2009 07:32:19 -0700 (PDT)
In-Reply-To: <1241790224.19651.40.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond:

BINGO!!!!
That was good!
Thank you thank you.
Does this mean that if I recreate the subdirectory, I have to do someth=
ing to
re-exportit? like exportfs -a nfsclient:/adir

I will keep going, but that is great so far!
Thank you very much,

Roger Marcus

trond:
Oh, you're using crossmnt to export the subdirectories? In that case,
why doesn't just 'exportfs -f' suffice to allow you to unmount them?


On Fri, May 8, 2009 at 3:43 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-05-08 at 15:11 +0200, Roger Marcus wrote:
>> Hi Trond,
>>
>> Thank you for your answer.
>>
>> exportfs does not report the individual directories that are mounted
>> on the exported directory, so I cannot use your script.
>>
>> on the nfsserver exports file:
>> /adir =A0 =A0 192.168.11.129(rw,sync,no_subtree_check,crossmnt,no_ro=
ot_squash)
>>
>> on the same machine:
>> mount -o loop virtual.iso virtualstuff
>> so now I have /adir/virtualstuff
>>
>> (which by the way, I can: =A0umount virtualstuff immediately without
>> problem and it releases.
>> however, if I run XEN on the client, then the directory is permanent=
ly
>> locked, ie, umount virtualstuff
>> DOESN'T work again unless I run exportfs -ua killing all connections
>> to the server.)
>>
>> the nfs-client sees /adir/virtualstuff, since parent /adir is mounte=
d.
>> When I run the virtualmachine within the virtualstuff directory (xm
>> create /adir/virtualstuff/config.cfg)
>> and then I destroy the virtualmachine (xm destroy /adir/virtualstuff=
/config.cfg)
>> I can never 'umount virtualstuff' from the nfsserver, even though no
>> one is accessing the directory
>> any more.
>>
>> So on the nfsserver I cannot umount virtualstuff. this is the bug.
>>
>> exportfs -ua =A0 =A0kills nfs for everybody, and then I can run 'umo=
unt
>> virtualstuff', but this is not what I want.
>> exportfs -u nfsclient:/adir =A0 =A0 =A0 doesn't even work. I don't w=
ant this
>> variation because I might be running 2 virtual machines
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0in two subdirectories.
>>
>> question: is the fact that ;exportfs -u nfsclient:/adir' doesn't wor=
k a bug?
>>
>> What I want to be able to do is from the nfsserver side, 'umount
>> virtualstuff', which I can do if I
>> 1) never run XEN, or
>> 2) exportfs -ua. The latter command kills all clients attached to th=
e server
>> so I cannot use this second command.
>> 3) the command 'exportfs -u nfsclient:/adir' doesn't work and this
>> might be a bug. I do not
>> want this variant since if I am running 2 virtual machines on the
>> nfsclient I would kill the other machine.
>>
>> In /proc/net/rpc/nfsd.export/content =A0 I see my virtualstuff
>> subdirectory referenced. Perhaps this
>> tells you something.
>>
>> Thank you in advance,
>>
>> Roger Marcus
>>
>
> Oh, you're using crossmnt to export the subdirectories? In that case,
> why doesn't just 'exportfs -f' suffice to allow you to unmount them?
>
> Trond
>
>
