From: David Liontooth <lionteeth-tj7FKCIresWsTnJN9+BGXg@public.gmane.org>
Subject: Re: No write access with recent versions of nfs-utils in Debian
Date: Sun, 30 Nov 2008 22:53:55 -0800
Message-ID: <49338A03.4040000@cogweb.net>
References: <4933101D.9000308@cogweb.net> <20081130231819.GA15303@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from weber.sscnet.ucla.edu ([128.97.42.3]:57553 "EHLO
	weber.sscnet.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805AbYLAGyD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 01:54:03 -0500
In-Reply-To: <20081130231819.GA15303-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar H. Gunderson wrote:
> On Sun, Nov 30, 2008 at 02:13:49PM -0800, David Liontooth wrote:
>   
>> Here's the verbose output of the version that didn't work, nfs-common   
>> 1:1.1.3-2:
>>     
>
> 1.1.3-2 is broken; do a dist-upgrade.
>
> /* Steinar */
>   
Thanks! Will the new version work against 1:1.1.0-5? I need to export to 
and mount from several systems I cannot upgrade.

Dave
