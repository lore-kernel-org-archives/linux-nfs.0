From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Tue, 6 Jul 2010 13:34:17 -0400
Message-ID: <AANLkTinU-cRmT6YSaa3XrKnjhbKitm-BzMtOwQ8MX4x5@mail.gmail.com>
References: <1277912631.11798.22.camel@localhost>
	<alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi>
	<1277918676.11798.58.camel@localhost>
	<alpine.DEB.2.00.1007020048220.17692@kosh.hut.fi>
	<1278079035.2834.0.camel@localhost>
	<AANLkTikusWEjVBEdtnR9fOSv4f_NgMBKK6BtWVLQ1nWf@mail.gmail.com>
	<1278342724.2834.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>, linux-nfs@vger.kernel.org
To: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56012 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755895Ab0GFRjs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 13:39:48 -0400
Received: by gye5 with SMTP id 5so1931053gye.19
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jul 2010 10:39:47 -0700 (PDT)
In-Reply-To: <1278342724.2834.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Unfortunately, the log messages and trace don't provide any new
information you haven't already provided.  I've been looking to see
whether there have been any (Kerberos) changes which would reject the
use of des-cbc-md5, but haven't found anything.  I'm not sure how to
proceed...

On Mon, Jul 5, 2010 at 11:12 AM, Laurent Bonnaud
<bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org> wrote:
> On Fri, 2010-07-02 at 10:17 -0400, Kevin Coffman wrote:
>>
>> The KDC hasn't changed, and is still Windows 2003?
>
> Yes it is. =A0However, according to my packet captures it is not invo=
lved
> during the mount operation.
>
>> Is there any extra
>> information logged if you increase the debug level for svcgssd
>> ("-vvv")?
>
> Here it is:
>
> [ ... ]
