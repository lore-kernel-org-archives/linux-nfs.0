Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm9-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.196]:38682 "HELO
	nm9-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755317Ab1EEPtO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 11:49:14 -0400
Message-ID: <437877.23899.qm@web111716.mail.gq1.yahoo.com>
References: <781436.95809.qm@web111709.mail.gq1.yahoo.com> <OF40F1C0BA.A5FC46BA-ON85257887.004DC668-85257887.004DD321@us.ibm.com> <591857.64709.qm@web111726.mail.gq1.yahoo.com> <BANLkTimbnz4xKyK1oNDnyWN7k9dhApW2TA@mail.gmail.com>
Date: Thu, 5 May 2011 08:49:13 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: debugging nfs
To: Hiroyuki Sato <hiroysato@gmail.com>
Cc: nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <BANLkTimbnz4xKyK1oNDnyWN7k9dhApW2TA@mail.gmail.com>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Hiroyuki,
 
I tried what you said, but no success. Here are the configs:
 
on server:
 
root@server:~# cat /etc/hosts
127.0.0.1       localhost     localhost,server
194.225.69.105  server
192.168.1.3     client1
192.168.1.4     client2
 
root@server:~# cat /etc/exports
/home/nfsroot        192.168.1.0/255.255.255.0(rw,async,no_root_squash)
/opt                 192.168.1.0/255.255.255.0(rw,sync,no_root_squash)

root@server:~# cat /etc/hosts.allow
sendmail: all
ALL: 192.168.1.0/255.255.255.0

 

On clients:
 
mahmood@client1:~$ cat /etc/fstab
# UNCONFIGURED FSTAB FOR BASE SYSTEM
# <file system> <mount point> <type> <options> <dump> <pass>
proc            /proc         proc   defaults       0      0
/dev/nfs        /             nfs    defaults       0      0
192.168.1.1:/opt       /opt          nfs    defaults       0      0
 
mahmood@client1:~$ cat /etc/hosts
127.0.0.1 localhost
192.168.1.1 server
192.168.1.3 client1
192.168.1.4 client2

 
However, there is no sign of proper automount:

mahmood@client1:~$ ls /opt/
mahmood@client1:~$


// Naderan *Mahmood;


----- Original Message -----
From: Hiroyuki Sato <hiroysato@gmail.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Brian R Cowan <brcowan@us.ibm.com>; nfs <linux-nfs@vger.kernel.org>
Sent: Thursday, May 5, 2011 7:55 PM
Subject: Re: debugging nfs

Hello Mahmood.

Have you ever tried to write ip address instead of server fqdn??
or have you ever tries write server entry in /etc/hosts??

It is mean that

/etc/fstab
ip.ad.re.ss:/opt /opt nfs mount_opt 0 0

or /etc/hosts
ip.add.re.ss server


I met same problem today, and I resolve it.

My friend were using NIS on scientific linux .
and It tried to mount before NIS started.

--
Hiroyuki Sato


2011/5/5 Mahmood Naderan <nt_mahmood@yahoo.com>:
> Well, I found the problem very nasty and in my previous posts, I mentioned some of them.
>
> The big problem:
> when the clients boots, it doesn't automatically mount the shared folders via /etc/fstab.
> However after login to client, I can mount the folder manually with
>
> "sudo mount -t nfs server:/opt /opt"
>
> I really don't know why fstab doesn't work. I searched a lot.... some say disbale IPV6.
> I did that but still have that problem.
>
> So how can I tell nfs (on server or client) to be verbose so that I can see what is going on
> and what is not going on.
>
> Any feedback and comment is welcomed.
>
> // Naderan *Mahmood;
>
> From: Brian R Cowan <brcowan@us.ibm.com>
> To: Mahmood Naderan <nt_mahmood@yahoo.com>
> Cc: nfs <linux-nfs@vger.kernel.org>; linux-nfs-owner@vger.kernel.org
> Sent: Thursday, May 5, 2011 6:40 PM
> Subject: Re: debugging nfs
>
>
> It would probably help to explain the problem
> so you can get targeted debugging assistance...
>
> =================================================================
> Brian Cowan
> Advisory Software Engineer
> ClearCase Software Advisory Team (SWAT)
> Rational Software
> IBM Software Group
> 550 King St
> Littleton, MA 01460
>
> Phone: 1.978.899.9471
> Web: http://www.ibm.com/software/rational/support/
>
>
>
>
> From:
>  Mahmood Naderan <nt_mahmood@yahoo.com>
> To:
>  nfs <linux-nfs@vger.kernel.org>,
> Date:
>  05/05/2011 09:30 AM
> Subject:
>    debugging nfs
> Sent by:
>    linux-nfs-owner@vger.kernel.org
>
>
>
> Hi,
> I didn't find a method for debugging NFS for debain based systems. Is there
> any verbose switch or debuging method for that?
>
> // Naderan *Mahmood;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

