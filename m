Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235Ab2CAPWc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 10:22:32 -0500
Message-ID: <4F4F9436.8090307@RedHat.com>
Date: Thu, 01 Mar 2012 10:22:30 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Gregor Gruener <ggruner@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2.6.32-131.6.1.el6.x86_64] idmapd.c: deactivate the ASCII
 characters check
References: <4F4603EC.9030404@redhat.com> <4F4E8F3A.8070708@RedHat.com> <20120229213838.GA1560@umich.edu>
In-Reply-To: <20120229213838.GA1560@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 02/29/2012 04:38 PM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   On 02/23/2012 04:16 AM, Gregor Gruener wrote:
>   > Customers are using Unicode characters umlauts (ö,ä,ü) in group names and this
>   > creates problems with NFS ID Mapping. Groups with umlauts will be redirected to
>   > the group NFS "nobody".
>   > This patch deactivate the ASCII characters check. It's maybe more like a temporary fix and I think it would be nicer to
>   > adjust the check to support Unicode characters instead to deactivate the check.
>   > Signed-off-by: Gregor Gruener<ggruner@redhat.com>
>   ...
>   Committed... 
> 
> I still think the name should be changed.  The only thing validateascii() is
> doing now is verifying that the string is null terminated.
Sorry Jim...  I kinda overlooked that part of the discussion... 
I guess validateascii() is not a published interface so we
could change it... any suggestions? (Patches always welcome! ;-) )

steved. 
