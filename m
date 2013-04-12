Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58082 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750800Ab3DLPK3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Apr 2013 11:10:29 -0400
Date: Fri, 12 Apr 2013 11:10:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bram Vandoren <brambi@gmail.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFS client hangs after server reboot
Message-ID: <20130412151026.GL7081@fieldses.org>
References: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com>
 <60201423.761959.1365722152352.JavaMail.root@erie.cs.uoguelph.ca>
 <CACQjR_Arj61HJ-QrKfccg=r38555U-43uwhqtwzrN3nd1uUO-Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CACQjR_Arj61HJ-QrKfccg=r38555U-43uwhqtwzrN3nd1uUO-Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 12, 2013 at 11:19:39AM +0200, Bram Vandoren wrote:
> > Just to clarify/correct what I posted yesterday...
> > The boot instance is the first 4 bytes of the clientid and the first
> > 4 bytes of the stateid.other. (Basically, for the FreeBSD server, a
> > stateid.other is just the clientid + 4 additional bytes that identify
> > which stateid related to the clientid that it is.)
> >
> > Those first 4 bytes should be the same for all clientids/stateid.others
> > issued during a server boot cycle. Any clientid/stateid.other with a
> > different first 4 bytes will get the NFS4ERR_STALE_CLIENTID/STATEID
> > reply.
> 
> Thanks for the clarification. I tried to reproduce the problem using a
> test setup but so far I didn't succeed. It's clearly not a problem
> that happens all the time. Also not all the clients lock up in the
> production system. Only a fraction of them (~ 1 in 10).
> 
> I checked the packets again. The Stateid in a read operation is:
> 9a:b6:5d:51:bc:07:00:00:24:23:00:00
> The client id:
> af:c1:63:51:8b:01:00:00

Yeah, so 9a:b6:5d:51 and af:c1:63:51 if you take them as little-endian
integers look like pretty reasonable recent dates in unix time, so that
agrees with Rick's description of the FreeBSD server's stateid and
clientid.

So that does sound like the client failing to toss an old stateid after
renew?

--b.

> 
> It seems we ended up with a stale stateid but with a valid client id.
> 
> I am going to do some more tests with mutiple clients to try to
> reproduce the problem. If that doesn't succeed I try to get the data
> from the production server when we have to reboot it next time (but
> this can take a while).
> 
> Thanks,
> Bram
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
