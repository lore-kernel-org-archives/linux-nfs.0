Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from a.mail.sonic.net ([64.142.16.245]:57992 "EHLO a.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478Ab1HUBOh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Aug 2011 21:14:37 -0400
Message-ID: <4E504505.6070807@corp.sonic.net>
Date: Sat, 20 Aug 2011 16:36:37 -0700
From: Kelsey Cummings <kgc@corp.sonic.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Odd locking behavior
References: <20110819230151.GD44681@corp.sonic.net> <1313859542.7693.5.camel@lade.trondhjem.org>
In-Reply-To: <1313859542.7693.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 8/20/2011 9:59 AM, Trond Myklebust wrote:
> Does the netapp filer have multiple NICs? There is a known bug with that
> in which the filer sends GRANTED calls from the wrong IP address: see
> the description at
> http://now.netapp.com/NOW/cgi-bin/bol?Type=Detail&Display=237430

Yes, it does.  I ran out of time but was starting to suspect that might 
be a problem.  It looks like maybe some older 2.4 clients are okay with 
this?  Don't ask.... :)

The Ontap version is suitably ancient due to heroic uptimes and (until 
now) no apparent bugs.  I doubt it has been upgraded (or crashed) since 
it was deployed when the 3020 was the hot new thing.  Looks like it's 
time to catch up.  ;)

Thanks for the tip!

-- 
Kelsey Cummings - kgc@corp.sonic.net      sonic.net, inc.
System Architect                          2260 Apollo Way
707.522.1000                              Santa Rosa, CA 95407
