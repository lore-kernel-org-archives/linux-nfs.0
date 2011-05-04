Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm24-vm4.bullet.mail.ne1.yahoo.com ([98.138.91.184]:47999 "HELO
	nm24-vm4.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754727Ab1EDRny convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 May 2011 13:43:54 -0400
Message-ID: <868905.93230.qm@web111721.mail.gq1.yahoo.com>
Date: Wed, 4 May 2011 10:43:52 -0700 (PDT)
From: Mahmood Naderan <nt_mahmood@yahoo.com>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: statd running as root
To: nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
On the client side I see this log
 
Apr  5 14:50:50 orca kernel: [   10.528336] udev: starting version 151
Apr  5 14:50:50 orca cron[1021]: (CRON) INFO (pidfile fd = 3)
Apr  5 14:50:50 orca cron[1032]: (CRON) STARTUP (fork ok)
Apr  5 14:50:51 orca cron[1032]: (CRON) INFO (Running @reboot jobs)
Apr  5 14:50:55 orca rpc.statd[704]: statd running as root. chown /var/lib/nfs/sm to choose different user
Apr  5 14:50:58 orca kernel: [   18.440010] eth0: no IPv6 routers present

 
However I don't know what to do
 
root@client:/home/mahmood# ls -l /var/lib/nfs/
total 12
drwxr-xr-x 2 root root 4096 2011-05-03 18:31 rpc_pipefs
drwxr-xr-x 2 root root 4096 2011-05-03 18:31 sm
drwxr-xr-x 2 root root 4096 2011-05-03 18:31 sm.bak

Any idea about that?
 
// Naderan *Mahmood;
