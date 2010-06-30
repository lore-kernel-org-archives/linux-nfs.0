From: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Wed, 30 Jun 2010 19:24:36 +0200
Message-ID: <1277918676.11798.58.camel@localhost>
References: <1277912631.11798.22.camel@localhost>
	 <alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Cc: linux-nfs@vger.kernel.org
To: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.ampere.inpg.fr ([147.171.64.83]:48184 "EHLO
	smtp.ampere.inpg.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756965Ab0F3RYi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 13:24:38 -0400
In-Reply-To: <alpine.DEB.2.00.1006301918360.17692-8U32XKBxp6oxHbG02/KK1g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-06-30 at 19:22 +0300, Timo Aaltonen wrote:

> Put that on the client as well and it should work.

Thank you for the suggestion !

Unfortunately the client already has the same /etc/krb5.conf file as the
server.  Any other idea ?

-- 
Laurent Bonnaud.


