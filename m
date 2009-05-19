From: Chuck Lever <chuck.lever@oracle.com>
Subject: RFC: merging sm-notify and rpc.statd
Date: Tue, 19 May 2009 10:36:14 -0400
Message-ID: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62010 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbZESOgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 10:36:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

As part of IPv6 support for NFS, I've been looking at rpc.statd and sm- 
notify.  IPv6 support touches so many parts of both, and the current  
open-coded RPC request schedulers in both can't support netids without  
major revision or replacement.  So I've decided to write a replacement  
instead of grafting in support for IPv6 to the current implementation.

For many reasons I'm thinking of merging sm-notify and rpc.statd back  
together.  The two were split only a few years ago, and it seems to me  
that it was done to support SuSE's in-kernel statd, which has since  
been effectively abandoned.

Having the two separated has ushered in a host of minor  
complications.  Packaging and init-scripts are more complicated.  Both  
executables have separate knowlege about /var/lib/nfs/{sm,sm.bak}.   
There are two separate man pages that share a lot of the same content.

So, what do you think about folding sm-notify back into rpc.statd?   
Steve suggested there may have been a customer issue that drove the  
separation.  Do you have any recollection of the issues?

For the rest of the list: are there strong dependencies outside RH and  
SuSE distributions that would require a separate sm-notify  
executable?  Any other issues?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



