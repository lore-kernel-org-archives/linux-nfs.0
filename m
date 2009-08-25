From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 15:55:20 -0400
Message-ID: <551A5C21-FB0F-4B77-B817-80A368A0F054@oracle.com>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com> <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com> <1251115893.6325.23.camel@heimdal.trondhjem.org> <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com> <1251226809.25372.29.camel@heimdal.trondhjem.org> <d4098e2f0908251206o34590902u9a69aed32142d67e@mail.gmail.com> <1251227539.25372.35.camel@heimdal.trondhjem.org> <d4098e2f0908251219w42340c9ak4538a22f8d7391b6@mail.gmail.com> <1251228350.25372.36.camel@heimdal.trondhjem.org> <5FC6E83A-4D26-4A77-B3F0-E34A9E97E9B5@oracle.com> <d4098e2f0908251245y4ed4a93bycf1a8cf902b18d84@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:28793 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750873AbZHYTzc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 15:55:32 -0400
In-Reply-To: <d4098e2f0908251245y4ed4a93bycf1a8cf902b18d84-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 25, 2009, at 3:45 PM, Stefan Egli wrote:
> Thanks Mates! I've seen those manuals but the bug I'm chasing doesn't
> seem to be documented ;)
>
> Just now that I got your attention :) one final clarification  
> question:
> * the attribute cache (==metadata cache) is part of the nfs client  
> code
> * the date (=file content) cache would be the normal linux caching

A file's mtime/ctime/atime is stored in the generic in-core inode.   
The inode cache is "normal linux caching".  File content is cached in  
the kernel's regular page cache, also considered "normal linux  
caching".  The difference for NFS files is how this information is  
updated and flushed back to persistent storage.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



