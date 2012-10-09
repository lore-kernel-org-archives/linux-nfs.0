Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hydra.rus.uni-stuttgart.de ([129.69.1.55]:42466 "EHLO
	hydra.rus.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754876Ab2JIT11 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Oct 2012 15:27:27 -0400
Date: Tue, 9 Oct 2012 21:27:24 +0200
From: David Werner <david.werner@iws.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Cc: eflorac@intellique.com
Subject: Re: Problem with NFSv4 (server: NetApp-Filer, client
 openSUSE-11.4, 12.1 and 12.2)
Message-ID: <20121009192724.GA12172@tindra.iws.uni-stuttgart.de>
References: <20121009135919.GA16012@tindra.iws.uni-stuttgart.de>
 <20121009162126.432516c2@harpe.intellique.com>
 <20121009150958.GB16012@tindra.iws.uni-stuttgart.de>
 <20121009181511.09686f13@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20121009181511.09686f13@harpe.intellique.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 09, 2012 at 06:15:11PM +0200, Emmanuel Florac wrote:
> Le Tue, 9 Oct 2012 17:09:59 +0200
> David Werner <david.werner@iws.uni-stuttgart.de> écrivait:
> 
> > 	rus4iws.rus.uni-stuttgart.de:/vol/rus4iws_data0/ on /home
> > type nfs4
> > (rw,relatime,sync,vers=4.0,rsize=65536,wsize=65536,namlen=255,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,noac,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=129.69.98.101,local_lock=none,addr=129.69.201.103)
> > 
> > But it did not resolve anything. 
> 
> Is the NetApp exported volume compressed by any chance? What does the
> output from "showmount -e <filer>" looks like for the related exports?

output of showmount -e: 

Export list for rus4iws.rus.uni-stuttgart.de:
/vol/rus4iws_data0
129.69.201.31,129.69.201.39,ikearw,ikea1,ikea2,ikea3,teleloch
/vol/rus4iws_vol0  129.69.201.31,129.69.201.39

The first line contains our netgroups and is the directory we mount.
I think some deduplication is enabled.
Today I made a test with ubuntu-12.04.1 client, with the same problem.

-- 
David Werner
Universitaet Stuttgart
Institut für Wasser- und Umweltsystemmodellierung
Lehrstuhl fuer Hydromechanik &  Hydrosystemmodellierung
Pfaffenwaldring 61 ** 70569 Stuttgart
Tel.: ++49-711-685 67010 ** Fax: ++49-711-685 60430
david.werner@iws.uni-stuttgart.de
