Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53209 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932730Ab1ERQUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 May 2011 12:20:51 -0400
Date: Wed, 18 May 2011 12:20:50 -0400
To: James Pearson <james-p@moving-picture.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for
 different client formats?
Message-ID: <20110518162050.GB16835@fieldses.org>
References: <4DD2A084.1040905@moving-picture.com>
 <20110518080106.1159c5b8@notabene.brown>
 <4DD39D39.7010805@moving-picture.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DD39D39.7010805@moving-picture.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 18, 2011 at 11:19:37AM +0100, James Pearson wrote:
> NeilBrown wrote:
> >
> >Unfortunately you cannot do that.
> >
> >The place in the code where this is determined is towards the end of
> >'lookup_export' in utils/mountd/cache.c
> >
> >Were I to try to 'fix' this I would probably define a new field in 'struct
> >exportent' which holds a 'priority'.
> >
> >Then allow a setting like "priority=4" in /etc/exports
> >
> >Then change the code in lookup_export to choose the one with the higher
> >priority, rather than the 'first' one.
> >
> >NeilBrown
> 
> I've hacked the source to make netgroups take precedence over
> subnets by  moving MCL_NETGROUP before MCL_SUBNETWORK in the enum in
> support/include/exportfs.h - which works for me, as I only use
> netgroups, subnets and anonymous (in that priority order).
> 
> IMHO the priority of exports should really be as they appear on the
> line in /etc/exports,

Sounds reasonable to me.

> but I guess if that were to change, it would
> break existing /etc/exports that use the current priority ordering
> (either by design or accident!).

Maybe some new /etc/exports syntax could allow the administrator to opt
into a new priority ordering.

> Having a priority option would be a very good idea - and may be in
> the meantime the exports man page should be updated with info about
> the current priority ordering?

Sounds good.  Could you send in a patch?

--b.
