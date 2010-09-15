Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.166.172.107]:42770 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab0IOO00 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 10:26:26 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o8FEQOTB026952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Wed, 15 Sep 2010 16:26:24 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o8FEQNRD031069
	for <linux-nfs@vger.kernel.org>; Wed, 15 Sep 2010 16:26:23 +0200
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o8FEQNtI015289
	for <linux-nfs@vger.kernel.org>; Wed, 15 Sep 2010 16:26:23 +0200
Message-ID: <4C90D78F.5000307@cea.fr>
Date: Wed, 15 Sep 2010 16:26:23 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: Jim Rees <rees@umich.edu>
CC: Benny Halevy <bhalevy@panasas.com>, peter honeyman <honey@citi.umich.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: Deploying a pNFS / LAYOUT4_BLOCK_VOLUME configuration
References: <4C8F6D39.2070406@cea.fr> <4C8F80DA.4030607@panasas.com> <20100915140429.GA30887@merit.edu>
In-Reply-To: <20100915140429.GA30887@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Jim,

>   The instructions are documented here:
>   http://wiki.linux-nfs.org/wiki/index.php/PNFS_Block_Server_Setup_Instructions
>   
I followed these instructions. Compiling the kernel is OK and so is 
compilation of pnfs-nfs-utils . I run client and server on F13. They 
both are virtual machines managed by virt-manager.

I used your start script to make one of my own (I had to change to 
argument to tgtadm related to the ip name of the iscsi array) but it was ok.
The only issue I have is about the ctl program. It stops as soon as it 
starts with this message:

    # ./ctl -u
    write: File exists

  
I then ran strace to know more about it and it showed this:

    munmap(0x7f5c533ac000, 47451)           = 0
    *open("/proc/fs/pnfs_block/ctl", O_RDWR) = 3*
    *write(3, "\1\0\0\0", 4)                 = -1 EEXIST (File exists)*
    dup(2)                                  = 4
    fcntl(4, F_GETFL)                       = 0x8002 (flags
    O_RDWR|O_LARGEFILE)
    fstat(4, {st_mode=S_IFCHR|0620, st_rdev=makedev(136, 0), ...}) = 0
    mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
    -1, 0) = 0x7f5c533b7000
    lseek(4, 0, SEEK_CUR)                   = -1 ESPIPE (Illegal seek)
    write(4, "write: File exists\n", 19write: File exists
    )    = 19
    close(4)                                = 0
    munmap(0x7f5c533b7000, 4096)            = 0
    exit_group(1)                           = ?

Apparently writing to /proc/fs/pnfs_block/ctl does not work. Do you have 
an idea on what I should do to fix this ?

> I have added a section on the block layout client to the Fedora client setup
> wiki page:
>
> http://wiki.linux-nfs.org/wiki/index.php/Fedora_pNFS_Client_Setup
>   
Is there a layoutdriver to modprobe on the client or is it embedded in 
the kernel itself ?

    Philippe

