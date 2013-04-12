Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f178.google.com ([209.85.128.178]:49038 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab3DLJUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Apr 2013 05:20:00 -0400
Received: by mail-ve0-f178.google.com with SMTP id c13so105568vea.37
        for <linux-nfs@vger.kernel.org>; Fri, 12 Apr 2013 02:19:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <60201423.761959.1365722152352.JavaMail.root@erie.cs.uoguelph.ca>
References: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com> <60201423.761959.1365722152352.JavaMail.root@erie.cs.uoguelph.ca>
From: Bram Vandoren <brambi@gmail.com>
Date: Fri, 12 Apr 2013 11:19:39 +0200
Message-ID: <CACQjR_Arj61HJ-QrKfccg=r38555U-43uwhqtwzrN3nd1uUO-Q@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Just to clarify/correct what I posted yesterday...
> The boot instance is the first 4 bytes of the clientid and the first
> 4 bytes of the stateid.other. (Basically, for the FreeBSD server, a
> stateid.other is just the clientid + 4 additional bytes that identify
> which stateid related to the clientid that it is.)
>
> Those first 4 bytes should be the same for all clientids/stateid.others
> issued during a server boot cycle. Any clientid/stateid.other with a
> different first 4 bytes will get the NFS4ERR_STALE_CLIENTID/STATEID
> reply.

Thanks for the clarification. I tried to reproduce the problem using a
test setup but so far I didn't succeed. It's clearly not a problem
that happens all the time. Also not all the clients lock up in the
production system. Only a fraction of them (~ 1 in 10).

I checked the packets again. The Stateid in a read operation is:
9a:b6:5d:51:bc:07:00:00:24:23:00:00
The client id:
af:c1:63:51:8b:01:00:00

It seems we ended up with a stale stateid but with a valid client id.

I am going to do some more tests with mutiple clients to try to
reproduce the problem. If that doesn't succeed I try to get the data
from the production server when we have to reboot it next time (but
this can take a while).

Thanks,
Bram
