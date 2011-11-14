Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:59992 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab1KNXgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 18:36:00 -0500
Message-ID: <4EC1A5CD.9040500@panasas.com>
Date: Mon, 14 Nov 2011 15:35:41 -0800
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Benny Halevy <benny@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: Subject: [PATCH] SQUASHME: pnfsd: nfs4pnfsd.c should dprint under
 NFSDDBG_PNFS
References: <4EB9F8D6.1080302@panasas.com> <20111109195510.GA2227@fieldses.org> <4EBBF605.9050403@panasas.com> <20111114230923.GA3718@fieldses.org>
In-Reply-To: <20111114230923.GA3718@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/14/2011 03:09 PM, J. Bruce Fields wrote:
> On Thu, Nov 10, 2011 at 08:04:21AM -0800, Boaz Harrosh wrote:
> 
> You mean the overuse of the state lock, or something else?
> 

Yes and the places that causes to unlock / lock because of
recursion or bad lock ordering.

So it's not as clean as it could be

Thanks
Boaz

> --b.
> 
>> Though it's better then the rest of the NFSD code.

