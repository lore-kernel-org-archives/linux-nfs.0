Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40378 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758060AbZBKVaI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Feb 2009 16:30:08 -0500
Message-ID: <4993435C.2090903@garzik.org>
Date: Wed, 11 Feb 2009 16:30:04 -0500
From: Jeff Garzik <jeff@garzik.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
CC: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: Re: NFS clients' use of fs_locations?
References: <49932E72.8060209@garzik.org> <1234387040.7423.287.camel@heimdal.trondhjem.org>
In-Reply-To: <1234387040.7423.287.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Wed, 2009-02-11 at 15:00 -0500, Jeff Garzik wrote:
>> According to the NFSv4 spec (section 6.1), regarding fs_locations,
>>
>> 	On first access of the filesystem, the client should obtain the
>> 	value of the fs_locations attribute. If, in the future, the
>> 	client finds the server unresponsive, the client may attempt to
>> 	use another server specified by fs_locations.
>>
>> Does any known client actually fail over to another fs_location, as 
>> described here?
>>
>> I am implementing the server side of this...  AFAICT Linux barely uses 
>> fs_locations, and Solaris just crashes.
> 
> Hi Jeff,
> 
> I'm working on finishing the migration code, and expect to have it ready
> soon.

Neat!  Will that include the simple fail-over actions described above?


> Until that, though, Bruce's suggestion of AIX is probably your best bet.
> AFAIK, they've had migration support in their client for several years.

Thanks!  Any idea at all if AIX client supports fail-over, or simply 
migration based on NFS4ERR_MOVED?

Time to figure out how to access AIX NFS client......  :)

	Jeff


