From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Thu, 24 Apr 2008 10:12:58 -0400
Message-ID: <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com>
References: <20080423214929.GA24387@uio.no>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33111 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757084AbYDXORO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2008 10:17:14 -0400
In-Reply-To: <20080423214929.GA24387-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steinar-

On Apr 23, 2008, at 5:49 PM, Steinar H. Gunderson wrote:
> I've gotten a few bug reports lately that if UDP is blocked at the  
> server,
> NFS mounts (even with -o tcp) fail. git bisect shows that the  
> culprit is
> the change "Get rid of the "-i" option for mount.nfs[4] and always  
> use the
> text-based mount(2) system call for kernel version 2.6.23 and  
> later." -- in
> other words, the bug is specific to the text interface. Does anyone  
> know why
> this would be the case?

I specifically tested that when developing the text-based mount  
interface, so if it doesn't work, it's a bug or a missed corner case.

Start with "mount.nfs -v" to see if the mount command tells you  
anything interesting.  Then do a raw network trace to see what's  
failing during the mount version/protocol negotiation.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
