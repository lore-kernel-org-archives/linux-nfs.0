From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH 2/2] lockd: Mostly remove BKL from the server
Date: Wed, 22 Sep 2010 11:43:02 -0400
Message-ID: <4C9A2406.6070100@netapp.com>
References: <4C9917B4.1010607@netapp.com> <20100922153702.GD15560@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35915 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751029Ab0IVPnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Sep 2010 11:43:18 -0400
In-Reply-To: <20100922153702.GD15560@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/22/2010 11:37 AM, J. Bruce Fields wrote:
> On Tue, Sep 21, 2010 at 04:38:12PM -0400, Bryan Schumaker wrote:
>> lockd: Mostly remove BKL from the server
>>
>> This patch removes all but one call to lock_kernel() from the server.
> 
> Thanks.  Does this need to go in any particular order with respect to
> the other BKL patches, or should I just apply this whenever?
> 
> --b.

It doesn't use lock_flocks(), so you should be able to apply it whenever.  

-Bryan
