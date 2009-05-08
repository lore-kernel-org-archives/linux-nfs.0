From: Roger Marcus <roger.marcus@gmail.com>
Subject: Re: Problem with NFS and XEN
Date: Fri, 8 May 2009 10:11:12 +0200
Message-ID: <c4838b6b0905080111s25c6a185ic0d62823016a8897@mail.gmail.com>
References: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com>
	 <4A03DBFB.8010407@symantec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Rajesh Ghanekar <rajesh_ghanekar@symantec.com>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:37024 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbZEHILO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 04:11:14 -0400
Received: by bwz22 with SMTP id 22so1211160bwz.37
        for <linux-nfs@vger.kernel.org>; Fri, 08 May 2009 01:11:13 -0700 (PDT)
In-Reply-To: <4A03DBFB.8010407@symantec.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Rajesh/linux-nfs,

I am sorry but I didn't understand your comment, Rajesh. ("you don't
do umount from NFS client of NFS mounted filesystem.")
Does this mean "I should do an umount from an NFS client, or does it
mean I shouldn't do an umount from an NFS client."

In any case I did not nor do I want to umount the directory from the
NFS-client side.

I mounted an iso image on the nfs-server side, so that it would be
visible to the client.
After I use it, I want to umount it from the nfs-server side. It doesn'=
t umount.

(When I try to umount the parent directory from the client - I also
get "device is busy".)

=46rom the server if I type:
exportfs -u 192.168.11.129:/adir              (releasing the parent dir=
ectory).
this fails, and the subsequent umount /adir/virtualstuff        fails

However if I type:
exportfs -ua

then umount /adir/virtualstuff    succeeds.

Is it a bug that
exportfs -u address:/path_to_directory     fails to 'unbusy the directo=
ry',
but
exportfs -ua                                                  succeeds
and a subsequent umount /adir/virtualstuff succeeds.


I am using as a server, opensuse
Linux msi 2.6.27.21-0.1-default #1 SMP 2009-03-31 14:50:44 +0200
x86_64 x86_64 x86_64 GNU/Linux

regards and thanks in advance for your help,

Roger Marcus



On Fri, May 8, 2009 at 9:15 AM, Rajesh Ghanekar
<rajesh_ghanekar@symantec.com> wrote:
> you don't do umount from NFS client of NFS mounted filesystem.
>
> Roger Marcus wrote:
>>
>> Hi,
>>
>> I am having a problem with NFS and I thought that you could help me =
or
>> you could steer me to
>> someone who might be able to.
>>
>> The problem is this:
>>
>> An NFS Server mounts an image on a local directory, containing a XEN
>> virtual machine configuration file and a XEN image.
>>
>> An NFS Client computer sees the directory that was mounted remotely
>> and starts the XEN Virtual machine on the mounted directory.
>> The NFS Client computer then stops the XEN Virtual machine. So far, =
so
>> good. The machine ran. It stopped. The NFS Client
>> leaves the directory. No process is accessing that directory from th=
e
>> client side.
>>
>> Problem: The NFS Server cannot umount the local directory.
>> fuser returns no usage of the directory.
>> lsof returns no usage of the directory.
>> umount -f won't force umount the directory.
>>
>> What does work is exportfs -ua.
>>
>> This is not a good way to go, since it is planned that many clients
>> will be using the server; indeed many
>> clients will be using multiple subdirectories on the server.
>>
>> 1. Is this a XEN bug or an NFS bug?
>> 2. Is there some other command like exportfs in which you can just
>> disable the one local directory but maintain an
>> active mount on the parent directory?
>>
>> exports:
>> /adir =A0 =A0 192.168.11.129(rw,sync,no_subtree_check,crossmnt,no_ro=
ot_squash)
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> /adir/image.iso (contains xen vm stuff)
>> server executes: mount -o loop /adir/image.iso /adir/virtualstuff
>>
>> client mounts adir with mount -t nfs 192.168.11.22:/adir /adir
>> xm create /adir/virtualstuff/config.cfg
>> xm destroy virtual
>>
>> on the nfs-server:
>> umount /adir/virtualstuff (won't)
>>
>> only exportfs -ua works, but this defeats my purpose.
>>
>> Can you suggest anything?
>>
>> thanks in advance,
>>
>> Roger Marcus
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"=
 in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>>
>
>
>
