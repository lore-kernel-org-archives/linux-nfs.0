From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Fri, 2 Jul 2010 10:17:39 -0400
Message-ID: <AANLkTikusWEjVBEdtnR9fOSv4f_NgMBKK6BtWVLQ1nWf@mail.gmail.com>
References: <1277912631.11798.22.camel@localhost>
	<alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi>
	<1277918676.11798.58.camel@localhost>
	<alpine.DEB.2.00.1007020048220.17692@kosh.hut.fi>
	<1278079035.2834.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>, linux-nfs@vger.kernel.org
To: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:33951 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758666Ab0GBORl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 10:17:41 -0400
Received: by vws5 with SMTP id 5so3781289vws.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 07:17:40 -0700 (PDT)
In-Reply-To: <1278079035.2834.0.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 2, 2010 at 9:57 AM, Laurent Bonnaud
<bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org> wrote:
> On Fri, 2010-07-02 at 00:50 +0300, Timo Aaltonen wrote:
>>
>> Try forcing the encryption type in krb5.conf:
>>
>> default_tkt_enctypes = des-cbc-crc
>> default_tgs_enctypes = des-cbc-crc
>
> I did that both on the client and the server and the result is the
> same :<.
>

The KDC hasn't changed, and is still Windows 2003?  Is there any extra
information logged if you increase the debug level for svcgssd
("-vvv")?  Could you send, me and/or the list, packet traces taken
from the (NFS) client and the server?

K.C.
