Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3-g21.free.fr ([212.27.42.3]:59563 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473Ab2JITo5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 15:44:57 -0400
Date: Tue, 9 Oct 2012 21:44:37 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: David Werner <david.werner@iws.uni-stuttgart.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client openSUSE-11.4,
 12.1 and 12.2)
Message-ID: <20121009214437.7a01c1cf@galadriel.home>
In-Reply-To: <20121009192724.GA12172@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
	<20121009162126.432516c2@harpe.intellique.com>
	<20121009150958.GB16012@tindra.iws.uni-stuttgart.de>
	<20121009181511.09686f13@harpe.intellique.com>
	<20121009192724.GA12172@tindra.iws.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Tue, 9 Oct 2012 21:27:24 +0200 vous écriviez:

> The first line contains our netgroups and is the directory we mount.

Yes, nothing special apparently.

> I think some deduplication is enabled.
> Today I made a test with ubuntu-12.04.1 client, with the same problem.
> 

So this may be a kernel bug. I'll have a quick look.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
