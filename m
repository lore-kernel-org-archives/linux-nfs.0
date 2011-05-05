Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm5.bullet.mail.sp2.yahoo.com ([98.139.91.75]:23592 "HELO
	nm5.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751384Ab1EEG5q convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 02:57:46 -0400
Message-ID: <798194.79212.qm@web111706.mail.gq1.yahoo.com>
References: <868905.93230.qm@web111721.mail.gq1.yahoo.com> <20110505083843.6c6570d7@notabene.brown>
Date: Wed, 4 May 2011 23:57:45 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: statd running as root
To: NeilBrown <neilb@suse.de>
Cc: nfs <linux-nfs@vger.kernel.org>
In-Reply-To: <20110505083843.6c6570d7@notabene.brown>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>Choose a used - e.g. "statd-user", and then

The user I have in passwd file is: 
statd:x:103:65534::/var/lib/nfs:/bin/false

So I should run
chown statd /var/lib/nfs/sm

I forgot to mention the main problem, instead I asked for solution to the log.
The problem is that the client won't automatically mount the folders from 
/etc/fstab. After booting and login, I have to manually use "mount" command.

I searched a lot about that and some say (I found somethings in suse forum http://forums.opensuse.org/english/get-technical-help-here/network-internet/406148-opensuse-11-1-not-mounting-nfs-boot.html#post1934423)
that portmap is run before network manager. 

So the boot order is problematic.
 

// Naderan *Mahmood;


----- Original Message -----
From: NeilBrown <neilb@suse.de>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Sent: Thursday, May 5, 2011 3:08 AM
Subject: Re: statd running as root

On Wed, 4 May 2011 10:43:52 -0700 (PDT) Mahmood Naderan
<nt_mahmood@yahoo.com> wrote:

> Hi,
> On the client side I see this log
>  
> Apr  5 14:50:50 orca kernel: [   10.528336] udev: starting version 151
> Apr  5 14:50:50 orca cron[1021]: (CRON) INFO (pidfile fd = 3)
> Apr  5 14:50:50 orca cron[1032]: (CRON) STARTUP (fork ok)
> Apr  5 14:50:51 orca cron[1032]: (CRON) INFO (Running @reboot jobs)
> Apr  5 14:50:55 orca rpc.statd[704]: statd running as root. chown /var/lib/nfs/sm to choose different user
> Apr  5 14:50:58 orca kernel: [   18.440010] eth0: no IPv6 routers present
> 
>  
> However I don't know what to do
>  
> root@client:/home/mahmood# ls -l /var/lib/nfs/
> total 12
> drwxr-xr-x 2 root root 4096 2011-05-03 18:31 rpc_pipefs
> drwxr-xr-x 2 root root 4096 2011-05-03 18:31 sm
> drwxr-xr-x 2 root root 4096 2011-05-03 18:31 sm.bak
> 
> Any idea about that?
>  

I thought that

    chown /var/lib/nfs/sm to choose different user

was sufficiently clear.
Choose a used - e.g. "statd-user", and then


    chown statd-user /var/lib/nfs/sm

(of course you have to create the user first if it doesn't already exist).

NeilBrown
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

