From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
Subject: Re: permission denied with >= ~2.6.25
Date: Tue, 18 May 2010 10:34:17 +0200
Message-ID: <4BF25109.40300@itwm.fraunhofer.de>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de> <20100516175213.GA9225@lts032.itwm.fhg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:51708 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754101Ab0ERIeX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 May 2010 04:34:23 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4I8YIFr010835
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 18 May 2010 10:34:18 +0200
Received: from mail2.itwm.fhg.de ([131.246.191.79]:56861)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail2.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OEIFm-0004XA-Cv
	for linux-nfs@vger.kernel.org; Tue, 18 May 2010 10:34:18 +0200
In-Reply-To: <20100516175213.GA9225-DA0fgfH9LvLH7LAFlePENYQuADTiUCJX@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,


today I tried 2.6.34 on server/client with standard
hardware. After around the 69th checkout I had an
"Invalid cross-device link" Error.
(Before that it was EIO/EPERM)

Test ran for around 9 hours before it failed.

>svn: In directory 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc'
>svn: Can't move
'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h.tmp'
>to 'Kernel-pxe3-69.EZvgHTmbzv/include/asm-sparc/resource.h': Invalid
>cross-device link
>Mon May 17 23:46:32 CEST 2010,1
>runcounter: 69

Martin
