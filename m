Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp5-g21.free.fr ([212.27.42.5]:12297 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932451AbbBDQaf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 11:30:35 -0500
Date: Wed, 4 Feb 2015 17:30:39 +0100
From: Emmanuel Florac <eflorac@intellique.com>
To: dE <de.techno@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Cant get to export this particular directory.
Message-ID: <20150204173039.421c3192@harpe.intellique.com>
In-Reply-To: <54D24403.2080403@gmail.com>
References: <54D237A5.1050302@gmail.com>
	<20150204170356.14e1e381@harpe.intellique.com>
	<54D24403.2080403@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Wed, 04 Feb 2015 21:38:35 +0530
dE <de.techno@gmail.com> écrivait:

> No, the previous directory is (huge)
> 
> /dev/sda15 on /home/test/huge type reiser4 (rw,noatime)

And does exporting from some other place in the same filesystem
(/home/test/huge/whatever) work ?

I suppose reiser4 is 64 bits. what's the inode number of 
/home/test/huge/temp_small/subdir ?
I've seen problems on some systems mounting inodes with large (not 32
bits compatible) numbers.

Another problem I've seen was when mixing clients with 3.8 kernel and
servers with 3.2 kernels.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
