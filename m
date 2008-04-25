From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Sat, 26 Apr 2008 01:55:46 +0200
Message-ID: <20080425235546.GA9053@uio.no>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com> <20080425080128.GA4848@uio.no> <09F49D76-049E-47A0-B0AD-5A177F8433E6@oracle.com> <20080425142712.GA6119@uio.no> <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:56889 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbYDYXzt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 19:55:49 -0400
In-Reply-To: <4D5FA350-EED5-4204-8D70-E3BE5E400595@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2008 at 06:13:03PM -0400, Chuck Lever wrote:
> I just tried this specific use case.
>
> Because of the local packet filtering on the client, the kernel's RPC  
> client is getting -EPERM when trying to send the initial rpcbind  
> request.
>
> As far as I can see, nothing in the RPC client knows how to deal  
> specifically with that error code, so it punts the request, and the  
> mount fails.
>
> When I originally tested mount protocol/version negotiation, I used only 
> server-side filtering.

I checked the original bug report, and indeed it seems that the blocking was
on the client there as well. I'll ask the user to check what happens when the
filtering is done server-side instead.

There's also http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=476128, but I
believe that's a different bug.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
