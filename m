From: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Subject: Re: starting 90-second grace period
Date: Fri, 11 Dec 2009 23:39:30 +0530
Message-ID: <f5b5ebae0912111009i4c665758gab583a34dbaea0d9@mail.gmail.com>
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
	<1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com> <f5b5ebae0912110925o510667far7201adf429c18a5@mail.gmail.com>
	<1260554515.15701.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f171.google.com ([209.85.223.171]:62759 "EHLO
	mail-iw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758832AbZLKSJp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Dec 2009 13:09:45 -0500
Received: by iwn1 with SMTP id 1so617707iwn.33
        for <linux-nfs@vger.kernel.org>; Fri, 11 Dec 2009 10:09:50 -0800 (PST)
In-Reply-To: <1260554515.15701.0.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

then why is it 90 by default ... is it RFC/Protocol requirement ?

On Fri, Dec 11, 2009 at 11:31 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Fri, 2009-12-11 at 22:55 +0530, Tharindu Rukshan Bamunuarachchi
> wrote:
>> thankx a lot for the info.
>>
>> btw, if i set nfs4leasetime to ~10 seconds ... is there any negative effect ?
>>
>
> You mean aside from the very likely event that your clients will lose
> all their locks when the server reboots?
>
> Trond
>
>



-- 
Tharindu Rukshan Bamunuarachchi
