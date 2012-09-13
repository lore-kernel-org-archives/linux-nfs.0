Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20335 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab2IMNIF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Sep 2012 09:08:05 -0400
Message-ID: <5051DAB1.8000006@netapp.com>
Date: Thu, 13 Sep 2012 09:08:01 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Lennart Buhl <mail@hackmate.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: Failure when trying to mout nfs
References: <505122C8.1010106@hackmate.de>
In-Reply-To: <505122C8.1010106@hackmate.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have patches for this that just got queued up for 3.5-stable (if they're not there yet).  As a workaround, try checking that rpc.idmapd is running or add "create id_resolver * * /usr/sbin/nfsidmap %k %d" to your /etc/request-key.conf.

- Bryan

On 09/12/2012 08:03 PM, Lennart Buhl wrote:
> Hi Trond,
> 
> this mail would look really ugly if i pasted everything here, so i
> included everything as seperate attachments.
> 
> [1.] Failure when trying to mout nfs
> [2.] When I want to mount a nfs share from my home fileserver it does
> not work and I am dropped to tty12 which presents me the stack trace I
> also sent you. I'm on gentoo, it worked with the 3.3.8 kernel, so I only
> get the failure with 3.4.9. It's not a kernel panic, i can switch back
> to tty7 and continue using my computer but it would be nice to use nfs
> with the newer kernel version.
> The log is named kernel-log-for-nfs-bug
> I also uploaded it here: http://nopaste.info/1a8f0da0d5.html
> [3.] Keywords: nfs networking kernel
> [4.] Kernel version: attached in proc_version_output
> [5.] No Oops-message
> [6.] I ran the following command:
> 	sudo mount 10.1.1.13:/atlas /home/atlas/
> [7.] Environment
> [7.1.] Software: ver_linux
> [7.2.] Processor: proc_cpuinfo
> [7.3.] Module: proc_modules
> [7.4.] Drivers & hardware: proc_iomem and proc_ioports
> [7.5.] PCI: lspci_vvv
> [7.6.] SCSI: proc_scsi_scsi
> [7.7.] Other information that might be relevant to the problem:
>   server_etc_exports contains the nfs exports on the server.
>   Despite this is a client-side problem i thought it might be important.
> [X.] Other notes, patches, fixes, workarounds: Worked with 3.3.8
> 
> Best regards,
> Lennart Buhl
> 
> 

