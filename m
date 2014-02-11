Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mlbefw1.ngenready.com ([192.52.233.75]:59981 "EHLO
	mlbefw1.harris.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbaBKPDC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 10:03:02 -0500
From: "McAninley, Jason" <jmcaninl@harris.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: Question regard NFS 4.0 buffer sizes
Date: Tue, 11 Feb 2014 15:01:39 +0000
Message-ID: <322949BF788C8D468BEA0A321B79799098BDBB0A@MLBMXUS20.cs.myharris.net>
References: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
 <20140211143633.GB9918@fieldses.org>
In-Reply-To: <20140211143633.GB9918@fieldses.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the reply, Bruce.

> Are you using UDP or TCP?

TCP.

> And what do you mean by "maximum packet size"?

I'm generally referring to the Frame size (e.g. 32,626) and/or the TCP packet size (e.g. 32560) - The former being the size of the latter plus the ethernet/IP headers.

> To see if the maximum rsize/wsize is being used you'd need to look for
> the length of the data in a READ reply or WRITE call.

Right. When I check the contents of a WRITE RPC, I see "Data" length of 32768 (32k).

My understanding is that setting {r,w}size doesn't guarantee that will be the agreed-upon value. Apparently one must check the value in /proc. I have verified this by checking the value of /proc/XXXX/mounts, where XXXX is the pid for nfsv4.0-svc on the client. It is set to a value >32K.

> What actual problem are you trying to solve?  (Is your read or write
> bandwidth lower than you expected?)

I am trying to maximize throughout within a parallel processing cluster. We have GigE connections within our closed network and I would like to ensure we are fully utilizing our bandwidth. Additionally, I find a lot of information online (that is not outdated) suggests various Kernel/OS/NFS settings without giving details for why the settings should be modified.

Upon changing the rsize/wsize, I would have expected to see a change in the packet/payload size, but I do not.

-Jason
