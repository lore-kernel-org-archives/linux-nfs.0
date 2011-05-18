Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:47511 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756376Ab1ERKTj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2011 06:19:39 -0400
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1QMdqs-0006lR-0L
	for linux-nfs@vger.kernel.org; Wed, 18 May 2011 11:19:38 +0100
Message-ID: <4DD39D39.7010805@moving-picture.com>
Date: Wed, 18 May 2011 11:19:37 +0100
From: James Pearson <james-p@moving-picture.com>
To: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for different
 client formats?
References: <4DD2A084.1040905@moving-picture.com> <20110518080106.1159c5b8@notabene.brown>
In-Reply-To: <20110518080106.1159c5b8@notabene.brown>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NeilBrown wrote:
> 
> Unfortunately you cannot do that.
> 
> The place in the code where this is determined is towards the end of
> 'lookup_export' in utils/mountd/cache.c
> 
> Were I to try to 'fix' this I would probably define a new field in 'struct
> exportent' which holds a 'priority'.
> 
> Then allow a setting like "priority=4" in /etc/exports
> 
> Then change the code in lookup_export to choose the one with the higher
> priority, rather than the 'first' one.
> 
> NeilBrown

I've hacked the source to make netgroups take precedence over subnets by 
  moving MCL_NETGROUP before MCL_SUBNETWORK in the enum in 
support/include/exportfs.h - which works for me, as I only use 
netgroups, subnets and anonymous (in that priority order).

IMHO the priority of exports should really be as they appear on the line 
in /etc/exports, but I guess if that were to change, it would break 
existing /etc/exports that use the current priority ordering (either by 
design or accident!).

Having a priority option would be a very good idea - and may be in the 
meantime the exports man page should be updated with info about the 
current priority ordering?

Thanks

James Pearson
