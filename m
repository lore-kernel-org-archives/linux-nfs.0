From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Fri, 2 Jul 2010 00:50:52 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1007020048220.17692@kosh.hut.fi>
References: <1277912631.11798.22.camel@localhost>  <alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi> <1277918676.11798.58.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-1.hut.fi ([130.233.228.91]:36920 "EHLO smtp-1.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab0GAVvB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Jul 2010 17:51:01 -0400
In-Reply-To: <1277918676.11798.58.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Jun 2010, Laurent Bonnaud wrote:

> On Wed, 2010-06-30 at 19:22 +0300, Timo Aaltonen wrote:
>
>> Put that on the client as well and it should work.
>
> Thank you for the suggestion !
>
> Unfortunately the client already has the same /etc/krb5.conf file as the
> server.  Any other idea ?

Try forcing the encryption type in krb5.conf:

default_tkt_enctypes = des-cbc-crc
default_tgs_enctypes = des-cbc-crc


-- 
Timo Aaltonen
Systems Specialist, Aalto IT
