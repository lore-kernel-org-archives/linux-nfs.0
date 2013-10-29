Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw02.dd24.net ([193.46.215.43]:33067 "EHLO
	mailgw02.dd24.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab3J2BEW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Oct 2013 21:04:22 -0400
Message-ID: <1383008649.8774.70.camel@heisenberg.scientia.net>
Subject: Re: XATTRs in NFS?
From: Christoph Anton Mitterer <calestyo@scientia.net>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Anand Avati <aavati@redhat.com>,
        Dr Fields James Bruce <bfields@redhat.com>,
        Wheeler Ric <rwheeler@redhat.com>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dickson Steve <steved@redhat.com>
Date: Tue, 29 Oct 2013 02:04:09 +0100
In-Reply-To: <05E44689-68BD-43AE-A5C8-409883E84227@netapp.com>
References: <20131028180838.GG31322@fieldses.org>
	 <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com>
	 <1383007167.8774.52.camel@heisenberg.scientia.net>
	 <05E44689-68BD-43AE-A5C8-409883E84227@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-10-29 at 00:53 +0000, Myklebust, Trond wrote:
> Why do these nodes need access to the xattrs?
I have no concrete idea... I just know what these guys are doing not
why... AFAIK the files resembles event collections from scientific
measurements,... and what they store is how these events have been
processed.
I do not even claim that this couldn't be done otherwise... it's just
how things are.

> What applications are they running that need them?
Home brew event processing software... 

>  Why can't those applications run on the native cluster instead?
That's largely politics and money...
The super computer is highly expensive and you only get time there after
you've made a official proposal and a commission has granted you're
request.
So while some of the data lies there in the shared fs (the GPFS),...
people also want to process the data from the normal Linux cluster
(where getting computing time is far more easy)... so they somehow need
to access the data which is done via the NFS exports.


Don't get me wrong, Trond, I'm not saying that this is the only or best
solution... I say this is how things are done in reality.
Obviously they must have found some workaround now... but I just wanted
to point out that there *are* some use cases, whether they're perfect or
not.


Cheers,
Chris.

