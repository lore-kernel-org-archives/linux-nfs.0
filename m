Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:29712 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab1FJFg5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 01:36:57 -0400
From: <tao.peng@emc.com>
To: <benny@tonian.com>, <rees@umich.edu>
CC: <bergwolf@gmail.com>, <linux-nfs@vger.kernel.org>, <honey@citi.umich.edu>
Date: Fri, 10 Jun 2011 01:36:05 -0400
Subject: RE: [PATCH 87/88] Add configurable prefetch size for layoutget
Message-ID: <F19688880B763E40B28B2B462677FBF805BED9D217@MX09A.corp.emc.com>
References: <cover.1307464381.git.rees@umich.edu>
 <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com> <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
 <4DF062D6.7010304@panasas.com> <20110609114929.GA28157@merit.edu>
 <4DF0CB5D.60000@panasas.com> <20110609135846.GA32565@merit.edu>
 <4DF139D0.1080200@tonian.com>
In-Reply-To: <4DF139D0.1080200@tonian.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi, Benny,

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Benny Halevy
Sent: Friday, June 10, 2011 5:23 AM
To: Jim Rees
Cc: Peng Tao; linux-nfs@vger.kernel.org; peter honeyman
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget

On 2011-06-09 06:58, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   > My understanding is that layoutget specifies a min and max, and the server
>   
>   There's a min.  What do you consider the max?
>   Whatever gets into csa_fore_chan_attrs.ca_maxresponsesize?
> 
> The spec doesn't say max, it says "desired."  I guess I assumed the server
> wouldn't normally return more than desired.

No, the server may freely upgrade the returned layout segment by returning
a layout for a larger byte range or even returning a RW layout where a READ
layout was asked for.
[PT] It is true that server can upgrade the layout segment freely. But there is always a price to pay. Server has to be dealing with all kind of clients.
If server returns more than being asked for, it may hurt other clients.

