Return-Path: linux-nfs-owner@vger.kernel.org
Received: from charon.rus.uni-stuttgart.de ([129.69.1.54]:49471 "EHLO
	charon.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756116Ab2JIPKB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 11:10:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP id C40EF5FDA2
	for <linux-nfs@vger.kernel.org>; Tue,  9 Oct 2012 17:09:59 +0200 (CEST)
Received: from charon.rus.uni-stuttgart.de ([127.0.0.1])
	by localhost (charon.rus.uni-stuttgart.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YXVoBllG3Lru for <linux-nfs@vger.kernel.org>;
	Tue,  9 Oct 2012 17:09:59 +0200 (CEST)
Received: from tindra.iws.uni-stuttgart.de (tindra.iws.uni-stuttgart.de [129.69.98.190])
	by charon.rus.uni-stuttgart.de (Postfix) with ESMTP
	for <linux-nfs@vger.kernel.org>; Tue,  9 Oct 2012 17:09:59 +0200 (CEST)
Date: Tue, 9 Oct 2012 17:09:59 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121009150958.GB16012@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
 <20121009162126.432516c2@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121009162126.432516c2@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Emmanuel,

Mount shows the following options which resulted from "defaults,_netdev"
in fstab: 

	rus4iws.rus.uni-stuttgart.de:/vol/rus4iws_data0/ on /home type nfs4
	(rw,relatime,vers=4.0,rsize=65536,wsize=65536,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=129.69.98.101,local_lock=none,addr=129.69.201.103,_netdev)

I now also tried with "noac" and without _netdev (where I forgot its meaning .. I think it was a recommendation to cirumvent some systemd boot problem)
like the following:

	rus4iws.rus.uni-stuttgart.de:/vol/rus4iws_data0/ on /home type nfs4
	(rw,relatime,sync,vers=4.0,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=129.69.98.101,local_lock=none,addr=129.69.201.103)

But it did not resolve anything. 

Best regards,
	David
