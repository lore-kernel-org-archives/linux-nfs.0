Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:35101 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751953AbbGVHb3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jul 2015 03:31:29 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 1166F280739
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 09:31:26 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 04B4F13EAC
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2015 09:31:25 +0200 (MEST)
Date: Wed, 22 Jul 2015 09:31:24 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>, linux-nfs@vger.kernel.org
Message-ID: <1412102138.7789329.1437550284656.JavaMail.zimbra@desy.de>
In-Reply-To: <20150721160338.GD11050@fieldses.org>
References: <55AE4FC6.6050001@bio.ifi.lmu.de> <20150721160338.GD11050@fieldses.org>
Subject: Re: Are there really no server-side mount/umount message for NFSv4?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With NFSv4.1 there are indirect hints to mount/umount: create and
destroy session.

Tigran.

----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Frank Steiner" <fsteiner-mail1@bio.ifi.lmu.de>
> Cc: linux-nfs@vger.kernel.org
> Sent: Tuesday, July 21, 2015 6:03:38 PM
> Subject: Re: Are there really no server-side mount/umount message for NFSv4?

> On Tue, Jul 21, 2015 at 03:57:26PM +0200, Frank Steiner wrote:
>> we are missing the "authenticated u/mount request..." messages or
>> error messages like "refused mount request from /x (/): not exported"
>> for NFSv4 servers. We were using the mount/umount messages e.g. to
>> detect when some reached a certain point of an installation etc.
>> And the error messages on the server side often were more helpful
>> than the ones on the client.
>> 
>> Is there really no way to get these easy-to-understand messages?
>> Debugging shows a lot but nothing that e.g. gives an understandable
>> error reason.
> 
> There aren't any mount or umount calls in the NFSv4 protocol.
> 
> (For example, an NFSv4 server typically wouldn't have any way to tell
> the difference between a client that has unmounted and one that just
> isn't using the filesystem right now.)
> 
> If you could describe in more detail your use case, someone might be
> able to suggest a different solution.  Or it might influence what sort
> of information the nfs server exports to users in the future.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
