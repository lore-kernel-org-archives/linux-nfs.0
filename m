Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp5-g21.free.fr ([212.27.42.5]:55873 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284AbaIZHvr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 03:51:47 -0400
Date: Fri, 26 Sep 2014 09:52:20 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: MJ Jenkins <mack.jenkins@eas.gatech.edu>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: NFS Share To OS X
Message-ID: <20140926095220.61235200@galadriel.home>
In-Reply-To: <54245661.8010107@eas.gatech.edu>
References: <5424156C.8080602@eas.gatech.edu>
	<20140925183034.432731eb@harpe.intellique.com>
	<54245661.8010107@eas.gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Thu, 25 Sep 2014 13:52:33 -0400 vous écriviez:

> 192.168.129.169(rw,all_squash,no_subtree_check,insecure,anonuid=0) 

Well you're squashing every user (all_squash) to the anonymous uid 0
(which is root). So you obtain the expected behaviour. Why did you put
these options in the first place?

The only special option you need is "insecure" for BSD (including Mac OS
X) clients.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
