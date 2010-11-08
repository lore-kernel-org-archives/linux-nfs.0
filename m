From: TH Chew <teonghan@gmail.com>
Subject: Re: Unable to unlock nfs4 mounted file
Date: Mon, 8 Nov 2010 11:01:38 +0800
Message-ID: <AANLkTi=hGbfqVGQGqwnfdOAnfqG=7eL5+EzFhi38qn=a@mail.gmail.com>
References: <1288962385.3936.6.camel@aikhan-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Dr. Md. Aminul Islam Khan" <aikhan_lab-jH00EaABlX1eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:50323 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074Ab0KHDBl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Nov 2010 22:01:41 -0500
Received: by eye27 with SMTP id 27so2560208eye.19
        for <linux-nfs@vger.kernel.org>; Sun, 07 Nov 2010 19:01:40 -0800 (PST)
In-Reply-To: <1288962385.3936.6.camel@aikhan-laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Maybe you can provide us with your /etc/exports content?

On Fri, Nov 5, 2010 at 9:06 PM, Dr. Md. Aminul Islam Khan
<aikhan_lab-jH00EaABlX1eoWH0uzbU5w@public.gmane.org> wrote:
>
> Hi,
> My nfs server is on Debian lenny.
> Using nfs clients a, b and c on Ubuntu 9.04
> Client a opened nfs4 served file "xxx.odt" and closed it.
> Client a tries to open the file, message is:
> Document file 'xxx.odt' is locked for editing by:
> khan (16.04.2010 21:08)
> Open document read-only or open a copy of the document for editing.
>
> Help in unlocking the file is highly appreciated
>
>
> Regards
>
> aikhan
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html



--
Regards,
THChew
