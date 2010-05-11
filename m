Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:37614 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985Ab0EKLC2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 May 2010 07:02:28 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4BB2Ppk032372
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 11 May 2010 13:02:26 +0200
Received: from mail1.itwm.fhg.de ([131.246.191.78]:41657)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail1.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OBnEH-00001E-NG
	for linux-nfs@vger.kernel.org; Tue, 11 May 2010 13:02:25 +0200
Message-ID: <4BE93940.5070804@itwm.fraunhofer.de>
Date: Tue, 11 May 2010 13:02:24 +0200
From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
To: linux-nfs@vger.kernel.org
Subject: Re: permission denied with >= ~2.6.25
References: <4BE7ED5D.90801@itwm.fraunhofer.de>
In-Reply-To: <4BE7ED5D.90801@itwm.fraunhofer.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Martin Vogt wrote:
> Hello list,
> 
> recently I updated my client to a new vendor kernel(SLES11), but the
> problem is the same if I use a 2.6.33.3 as a client.
> 
> If I'm doing svn checkouts in an endless loop,
> or running make -j X builds sometimes it happens
> that I get a "Permision denied" error.
> 

Hello,

I tested 2.6.34-rc7 now and it has the problem too.
Then I checked 2.6.24.7 which has the problem,
but 2.6.23.1 looks fine.

>svn: In directory 'Kernel.9TKDNMQTDm/arch/arm/mach-realview'
>svn: Error processing command 'readonly' in
>'Kernel.9TKDNMQTDm/arch/arm/mach-realview'
>svn: Can't change perms of file
>'Kernel.9TKDNMQTDm/arch/arm/mach-realview/.svn/text-base/Makefile.boot.svn-base':
>Permission denied
>Tue May 11 12:57:51 CEST 2010,1
>runcounter: 1
>vogt@pxe3[vogt_nfs]>uname -a
>Linux pxe3.itwm.fhg.de 2.6.34-rc7-0.1-default #2 SMP Tue May 11
>10:28:41 CEST 2010 x86_64 x86_64 x86_64 GNU/Linux


Usually the "permission denied" happens very early. In this case the
first run.

regards,

Martin


