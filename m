Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp4-g21.free.fr ([212.27.42.4]:34947 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752049Ab2JIQPP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 12:15:15 -0400
Date: Tue, 9 Oct 2012 18:15:11 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: David Werner <david.werner@iws.uni-stuttgart.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client openSUSE-11.4,
 12.1 and 12.2)
Message-ID: <20121009181511.09686f13@harpe.intellique.com>
In-Reply-To: <20121009150958.GB16012@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
	<20121009162126.432516c2@harpe.intellique.com>
	<20121009150958.GB16012@tindra.iws.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Tue, 9 Oct 2012 17:09:59 +0200
David Werner <david.werner@iws.uni-stuttgart.de> écrivait:

> 	rus4iws.rus.uni-stuttgart.de:/vol/rus4iws_data0/ on /home
> type nfs4
> (rw,relatime,sync,vers=4.0,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=129.69.98.101,local_lock=none,addr=129.69.201.103)
> 
> But it did not resolve anything. 

Is the NetApp exported volume compressed by any chance? What does the
output from "showmount -e <filer>" looks like for the related exports?

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
