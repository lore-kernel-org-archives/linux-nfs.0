Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from filter.openoffice.nl ([217.170.2.175]:45041 "EHLO
	filter.openoffice.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752958Ab0KRJ7y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Nov 2010 04:59:54 -0500
Message-ID: <4CE4F910.4080601@blub.net>
Date: Thu, 18 Nov 2010 10:59:44 +0100
From: Valentijn Sessink <valentyn@blub.net>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: no_root_squash (and valid KRB root-ticket)
References: <4CE294DD.6010508@blub.net>	<4CE3B3B9.8040208@openoffice.nl> <AANLkTi=Vhz+BSeGtYOUavf9Lq0ms2hLjTUyuvGt0gMxj@mail.gmail.com>
In-Reply-To: <AANLkTi=Vhz+BSeGtYOUavf9Lq0ms2hLjTUyuvGt0gMxj@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kevin Coffman schreef:
> Did you see my message about "static" mapping for libnfsidmap?

Yes, but it's scope was not immediately clear to me. Also, I couldn't
find the mapping feature you were mentioning; but my idmapd man page
comes from the nfs-common sources, while your idmapd.conf example (as
you explained) comes from libnfsidmap.

> On your server, you can map "host/client.machine@REALM" to root.  (Or
> "nfs/client.machine@REALM" or "root/client.machine@REALM", depending
> on what key you have on the client.)

OK, now I understand :) As far as I can see, that would mean that anyone
with root rights on the client (thus being able to read the machine
keys) would have root rights on the server share, wouldn't it?

Best regards,

Valentijn

