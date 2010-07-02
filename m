From: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Fri, 02 Jul 2010 15:57:15 +0200
Message-ID: <1278079035.2834.0.camel@localhost>
References: <1277912631.11798.22.camel@localhost>
	 <alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi>
	 <1277918676.11798.58.camel@localhost>
	 <alpine.DEB.2.00.1007020048220.17692@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: linux-nfs@vger.kernel.org
To: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ampere.inpg.fr ([147.171.64.83]:49345 "EHLO
	smtp.ampere.inpg.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752Ab0GBN5R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 09:57:17 -0400
In-Reply-To: <alpine.DEB.2.00.1007020048220.17692-8U32XKBxp6oxHbG02/KK1g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-07-02 at 00:50 +0300, Timo Aaltonen wrote:
> 
> Try forcing the encryption type in krb5.conf:
> 
> default_tkt_enctypes = des-cbc-crc
> default_tgs_enctypes = des-cbc-crc 

I did that both on the client and the server and the result is the
same :<.

-- 
Laurent Bonnaud.
http://www.lis.inpg.fr/pages_perso/bonnaud/


