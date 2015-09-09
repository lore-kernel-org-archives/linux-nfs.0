Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:55404 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752119AbbIIUKa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 16:10:30 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 232532803BE
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2015 22:10:29 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 1617013EAD
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2015 22:10:28 +0200 (MEST)
Date: Wed, 9 Sep 2015 22:10:28 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1769158187.6826766.1441829428223.JavaMail.zimbra@desy.de>
In-Reply-To: <20150909190308.GB25750@fieldses.org>
References: <267164181.6444770.1441717712553.JavaMail.zimbra@desy.de> <20150909190308.GB25750@fieldses.org>
Subject: Re: readdir and old cookie verifier
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> Sent: Wednesday, September 9, 2015 9:03:08 PM
> Subject: Re: readdir and old cookie verifier

> On Tue, Sep 08, 2015 at 03:08:32PM +0200, Mkrtchyan, Tigran wrote:
>> 
>> Dear NFS gurus,
>> 
>> we run into situation, where client gets BAD_COOKIE on a readdir.
>> Before I go and try to adopt our server to handle it, let me describe
>> the situation.
>> 
>> A client node (we have seen it with RHEL6 and Ubuntu 12.04, but probably
>> others affected as well) send a bunch of readdirs to the server. After some
>> time (this many be hours, days ) client sends an other set of readdirs.
> 
> Starting over with cookie zero, or resuming using some cached cookie?

It resuming with a cached cookie. Looks like the client still has a first portion
of the listing, and want's to fetch the rest. At least in one case we found that
application does a opendir and series of readdirs but with a big delay (iterates over
files in a directory).

> 
>> But
>> it reuses cookie verifier from the first readdir sequence. Server sends back
>> BAD_COOKIE, but client never starts over with a cookie and verifier being zero.
> 
> I don't think it's really required to do that.  7530 suggests that might
> indeed result in an error:
> 
>	It should be a rare occurrence that a server is unable to
>	continue properly reading a directory with the provided
>	cookie/cookieverf pair.  The server should make every effort to
>	avoid this condition since the application at the client may not
>	be able to properly handle this type of failure.
> 
> (Also, RFC 7530 16.24.4 says NOT_SAME is the error in this case.  Is
> that really correct?  I would have expected BAD_COOKIE too.)

Well, it makes sense to me. If a client asks for a content of a directory
which is changed, how one can provide that listing? On the other hand,
if we always return NOT_SAME, then client will never the that listing and
endup with infinite READDIR loop.

> 
>> As a result, inconsistent listing and anhappy user:
>> 
>> 
>> [exflserv04] ~ $ ls /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/
>> ls: reading directory /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/:
>> Unknown error 523
> 
> That's EBADCOOKIE.
> 
>> Is this behavior of the client correct?
> 
> I think so.  It's a huge pain for filesystems, but unfortunately readdir
> cookies (like filehandles) are forever.

I already have raised this issue.

https://www.ietf.org/mail-archive/web/nfsv4/current/msg07267.html

Probably I have to bring it once again. Specs (v3, v4,+) doesn't
talk about permanent cookies.

My guess is that client assumes that old verifier is ok as it didn't detect
any changes in attributes. For now, we will update our server to generate a new
listing (in our system, directory listings are virtual objects and generated on
demand) with a hope, that we will get the same result (and the same verifier).

Tigran. 

> 
> --b.
