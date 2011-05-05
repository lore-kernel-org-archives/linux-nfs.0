Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46780 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754804Ab1EEPZg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2011 11:25:36 -0400
Received: by wya21 with SMTP id 21so1702678wya.19
        for <linux-nfs@vger.kernel.org>; Thu, 05 May 2011 08:25:35 -0700 (PDT)
In-Reply-To: <591857.64709.qm@web111726.mail.gq1.yahoo.com>
References: <781436.95809.qm@web111709.mail.gq1.yahoo.com>
	<OF40F1C0BA.A5FC46BA-ON85257887.004DC668-85257887.004DD321@us.ibm.com>
	<591857.64709.qm@web111726.mail.gq1.yahoo.com>
Date: Fri, 6 May 2011 00:25:34 +0900
Message-ID: <BANLkTimbnz4xKyK1oNDnyWN7k9dhApW2TA@mail.gmail.com>
Subject: Re: debugging nfs
From: Hiroyuki Sato <hiroysato@gmail.com>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Brian R Cowan <brcowan@us.ibm.com>, nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

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
