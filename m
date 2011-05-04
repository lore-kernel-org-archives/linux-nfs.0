Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:54492 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753011Ab1EDWiw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 18:38:52 -0400
Date: Thu, 5 May 2011 08:38:43 +1000
From: NeilBrown <neilb@suse.de>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Subject: Re: statd running as root
Message-ID: <20110505083843.6c6570d7@notabene.brown>
In-Reply-To: <868905.93230.qm@web111721.mail.gq1.yahoo.com>
References: <868905.93230.qm@web111721.mail.gq1.yahoo.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
