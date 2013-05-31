Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f173.google.com ([209.85.128.173]:48648 "EHLO
	mail-ve0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3EaQfl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 May 2013 12:35:41 -0400
Received: by mail-ve0-f173.google.com with SMTP id jw11so1299774veb.4
        for <linux-nfs@vger.kernel.org>; Fri, 31 May 2013 09:35:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1562611687.61201.1369914919633.JavaMail.root@erie.cs.uoguelph.ca>
References: <CACQjR_DV_2QFd0O1e6R6M34_R87+Bn+zvn3w_BkhS9YESNVUzg@mail.gmail.com>
 <1562611687.61201.1369914919633.JavaMail.root@erie.cs.uoguelph.ca>
From: Bram Vandoren <brambi@gmail.com>
Date: Fri, 31 May 2013 18:35:20 +0200
Message-ID: <CACQjR_CsRY4O+S1Zx-QabXYBUtRMKHa8o7ymCmLqSHa9UdgNFQ@mail.gmail.com>
Subject: Re: NFS client hangs after server reboot
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Did both the client and server have the same IP addresses before the
> reboot?

Yes.

> If not, the Linux client's nfs_client_id4.id SetClientID argument
> will be different (it has the client/side IP# in it). nfs_client_id4.id
> isn't supposed to change for a given client when it is rebooted.
> That will make the FreeBSD NFSv4 server see "new client" (which is not in the
> stablerestart file used to avoid certain reboot edge conditions) and
> will not give it a grace period.
> This is the only explanation I can think of for the NFS4ERR_NO_GRACE
> reply shortly after the reboot.

I checked some other clients and they all receive the
NFS4ERR_NO_GRACE response from the server. It's not unique for the
clients that hang. I was unable to reproduce this is a minimal test
configuration. Perhaps the nfs-stablerestart file is corrupt on the
server?

I checked
 strings nfs-stablerestart
and I see a lot of duplicate entries. In total there are ~10000 lines
but we only have ~50 clients.
Most clients have 3 types of entries:
Linux NFSv4.0 a.b.c.d/e.f.g.h tcp
Linux NFSv4.0 a.b.c.d/e.f.g.h tcp*
Linux NFSv4.0 a.b.c.d/e.f.g.h tcp+

Again, thanks a lot for looking into this.

Bram.
