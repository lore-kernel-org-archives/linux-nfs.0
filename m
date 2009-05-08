From: Roger Marcus <roger.marcus@gmail.com>
Subject: Re: Problem with NFS and XEN
Date: Fri, 8 May 2009 15:11:42 +0200
Message-ID: <c4838b6b0905080611n3ef3f2efr3e843836b1e3dd@mail.gmail.com>
References: <c4838b6b0905072310g5658ed91i486797b76c8d95d3@mail.gmail.com>
	 <1241785441.19651.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:38969 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbZEHNLm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 May 2009 09:11:42 -0400
Received: by fxm2 with SMTP id 2so1388116fxm.37
        for <linux-nfs@vger.kernel.org>; Fri, 08 May 2009 06:11:42 -0700 (PDT)
In-Reply-To: <1241785441.19651.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Thank you for your answer.

exportfs does not report the individual directories that are mounted
on the exported directory, so I cannot use your script.

on the nfsserver exports file:
/adir     192.168.11.129(rw,sync,no_subtree_check,crossmnt,no_root_squash)

on the same machine:
mount -o loop virtual.iso virtualstuff
so now I have /adir/virtualstuff

(which by the way, I can:  umount virtualstuff immediately without
problem and it releases.
however, if I run XEN on the client, then the directory is permanently
locked, ie, umount virtualstuff
DOESN'T work again unless I run exportfs -ua killing all connections
to the server.)

the nfs-client sees /adir/virtualstuff, since parent /adir is mounted.
When I run the virtualmachine within the virtualstuff directory (xm
create /adir/virtualstuff/config.cfg)
and then I destroy the virtualmachine (xm destroy /adir/virtualstuff/config.cfg)
I can never 'umount virtualstuff' from the nfsserver, even though no
one is accessing the directory
any more.

So on the nfsserver I cannot umount virtualstuff. this is the bug.

exportfs -ua    kills nfs for everybody, and then I can run 'umount
virtualstuff', but this is not what I want.
exportfs -u nfsclient:/adir       doesn't even work. I don't want this
variation because I might be running 2 virtual machines
                                                 in two subdirectories.

question: is the fact that ;exportfs -u nfsclient:/adir' doesn't work a bug?

What I want to be able to do is from the nfsserver side, 'umount
virtualstuff', which I can do if I
1) never run XEN, or
2) exportfs -ua. The latter command kills all clients attached to the server
so I cannot use this second command.
3) the command 'exportfs -u nfsclient:/adir' doesn't work and this
might be a bug. I do not
want this variant since if I am running 2 virtual machines on the
nfsclient I would kill the other machine.

In /proc/net/rpc/nfsd.export/content   I see my virtualstuff
subdirectory referenced. Perhaps this
tells you something.

Thank you in advance,

Roger Marcus




On Fri, May 8, 2009 at 2:24 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-05-08 at 08:10 +0200, Roger Marcus wrote:
>> Hi,
>>
>> I am having a problem with NFS and I thought that you could help me or
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
>> The NFS Client computer then stops the XEN Virtual machine. So far, so
>> good. The machine ran. It stopped. The NFS Client
>> leaves the directory. No process is accessing that directory from the
>> client side.
>
> It is still exported, so the NFS server still has a reference to it.
>
>> Problem: The NFS Server cannot umount the local directory.
>> fuser returns no usage of the directory.
>> lsof returns no usage of the directory.
>
> correction: lsof and fuser don't show any _user processes_ that
> reference the directory. NFSd runs in the kernel...
>
>> umount -f won't force umount the directory.
>>
>> What does work is exportfs -ua.
>
> or 'exportfs -u client:/directory'. See 'man exportfs'
>
>> This is not a good way to go, since it is planned that many clients
>> will be using the server; indeed many
>> clients will be using multiple subdirectories on the server.
>>
>> 1. Is this a XEN bug or an NFS bug?
>> 2. Is there some other command like exportfs in which you can just
>> disable the one local directory but maintain an
>> active mount on the parent directory?
>
> See above.
>
> Note that if you want to unexport all export entries for a particular
> directory '/mydir', then something like this simple script will do it:
>
> exportfs -u $(exportfs | awk '/^\/mydir/ { print $2 ":" $1; }')
>
> Trond
>
>
