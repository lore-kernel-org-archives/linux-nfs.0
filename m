Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:54621 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751220AbcAGSkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Jan 2016 13:40:08 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1aHFTg-0001xh-Nh
	for linux-nfs@vger.kernel.org; Thu, 07 Jan 2016 19:40:04 +0100
Received: from 83.167.48.97.static.not.updated.neotelecoms.com ([83.167.48.97.static.not.updated.neotelecoms.com])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jan 2016 19:40:04 +0100
Received: from pierref by 83.167.48.97.static.not.updated.neotelecoms.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jan 2016 19:40:04 +0100
To: linux-nfs@vger.kernel.org
From: PIERRRE <pierref@buf.com>
Subject: Re: Debian kernel: 
Date: Thu, 7 Jan 2016 18:34:31 +0000 (UTC)
Message-ID: <loom.20160107T193055-318@post.gmane.org>
References: <55C3016A.9000509@aixigo.de> <20150811090949.5f1a2594@dpcl082.ac.aixigo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Harald Dunkel <harald.dunkel@...> writes:

> 
> PS:
> 
> /sys/module/nfs/parameters/nfs4_unique_id returns just an 
> empty string. I would have expected the hostname or a 
> similar string here, according to Documentation/filesystems/\
> nfs/nfs.txt . 
> 
> I am absolutely sure that there are no duplicate host names in 
> my net. The IP addresses are fixed, too. Nevertheless, to 
> avoid problems I have changed my setup procedure to set 
> nfs.nfs4_unique_id in grub, as suggested.
> 
> I am still hoping for valuable feedback
> 
> Regards
> Harri
> 


Hi,

I have the same issue with several NFS servers. Cannot find any help.

How did you fixed it with grub ?
And did you go further and find a solution though ?

NFS server debian 8.2
NFS client debian 8.2

Any help would be appreciate.


Pierre



