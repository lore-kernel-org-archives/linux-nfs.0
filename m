From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 24 Jan 2008 15:02:02 +1100
Message-ID: <18328.3514.149058.653547@notabene.brown>
References: <4781BB0D.90706@redhat.com>
	<20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org>
	<4788665B.4020405@redhat.com>
	<20080114230742.GA16975@fieldses.org>
	<18315.61638.14133.308991@notabene.brown>
	<20080122225312.GO24697@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Wendy Cheng <wcheng@redhat.com>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39571 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbYAXECM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2008 23:02:12 -0500
In-Reply-To: message from J. Bruce Fields on Tuesday January 22
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday January 22, bfields@fieldses.org wrote:
> 
> ?

!

(i.e. Acked-By: NeilBrown <neilb@suse.de>)

tnx.NB

> 
> --b.
> 
> commit 6685389d610950126f700d25f3d010c7049441c3
> Author: J. Bruce Fields <bfields@citi.umich.edu>
> Date:   Tue Jan 22 17:40:42 2008 -0500
> 
>     nfsd: more careful input validation in nfsctl write methods
>     
>     Neil Brown points out that we're checking buf[size-1] in a couple places
>     without first checking whether size is zero.
>     
>     Actually, given the implementation of simple_transaction_get(), buf[-1]
>     is zero, so in both of these cases the subsequent check of the value of
>     buf[size-1] will catch this case.
>     
>     But it seems fragile to depend on that, so add explicit checks for this
>     case.
>     
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>     Cc: Neil Brown <neilb@suse.de>
