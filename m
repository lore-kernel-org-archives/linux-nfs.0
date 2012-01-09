Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60944 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752424Ab2AIMt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jan 2012 07:49:58 -0500
Message-ID: <4F0AE25C.5020706@panasas.com>
Date: Mon, 9 Jan 2012 14:49:32 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] linux-pnfs server implementations
References: <4EF6A6CA.1020606@tonian.com>
In-Reply-To: <4EF6A6CA.1020606@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/25/2011 06:30 AM, Benny Halevy wrote:
> Now that the client side of pnfs is in the mainline kernel
> I believe it is time to consider the inclusion of the server side.
> 
> I propose the following agenda for discussion
> (order may change with no advance notice :)
> 
> * What's currently available in git://linux-nfs.org/~halevy/linux-pnfs.git
>   - What are the sub-projects
>   - How they relate to each other
> 
> * High-level design of the implementation
> 
> * Summary of generic changes in nfsd
> 
> * For each of the different sub-projects, briefly present:
>   - What does it do
>   - Benefits and Potential
>   - Limitations
>   - Status
>   - To-do
> 
> * Prerequisites for inclusion
> 
> * Discussion
> 

Me too! This subject is close to my heart, as exofs is the most
complete and advanced pNFSD base implementation. Last testing
has demonstrated amazing performance and scalability. Saturating
10G from a single client and saturating 4*10G storage cluster
from multiple clients.(Though there were problems with too many
clients)

> Benny

Thanks
Boaz
