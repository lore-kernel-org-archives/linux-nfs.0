Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:42794 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755418Ab2DEV0v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 17:26:51 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Thu, 05 Apr 2012 17:26:48 -0400
From: David Quigley <dpquigl@davequigley.com>
To: "Myklebust, Trond" <trond.myklebust@netapp.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: Another try at =?UTF-8?Q?LNFS=3F?=
In-Reply-To: <1333646141.4573.1.camel@lade.trondhjem.org>
References: <775e0a2cd5e2e4c8f52401214dbd9413@countercultured.net>
 <1333646141.4573.1.camel@lade.trondhjem.org>
Message-ID: <85614613274dbfef5253665a84a36374@countercultured.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/05/2012 13:15, Myklebust, Trond wrote:
> On Thu, 2012-04-05 at 13:02 -0400, David Quigley wrote:
>> Now that we're past the 3.4 merge window should I post the LNFS
>> modifications for review for when 3.5 rolls around?
>
> The sooner the better. It looks as if there will be quite a bit of 
> stuff
> going into 3.5, so it would be nice to maximise our testing window.
>
> Thanks!
>   Trond

I have a mostly working copy for 3.2 which I can forward port but I'm 
having an issue with it. The revalidate code changed at some point and 
just to get things working I dropped a piece of code from the patch set 
that I couldn't figure out how to transition to the new revalidate code. 
Unfortunately this is the initial get of the security label so the 
security label is invalid until the first cache invalidation. Any 
suggestions on where to place this code? I can give you the original 
code snippet when I get home that I dropped.

Dave
