From: Eric Veith <ERVEITH-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Subject: Re: nfs4 write delegation status
Date: Thu, 23 Jul 2009 10:12:05 +0200
Message-ID: <OF97D5D1D5.E19FBA13-ONC12575FC.002CE971-C12575FC.002D0D78@de.ibm.com>
References: <fe2cbb740907211447t4dfcc0dara63bb96648599638@mail.gmail.com> <20090722163810.GB4491@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David V. Cloud" <david.v.cloud@gmail.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:38398 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbZGWIMU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2009 04:12:20 -0400
In-Reply-To: <20090722163810.GB4491@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

> I really don't want to enable write delegations until we figure out how
> to enforce them correctly against local (non-nfs) users of the exported
> filesystem as well.  In addition to breaking delegations on read opens,
> that means breaking delegations or doing a cb_getattr on operations like
> stat.

do you know whether there are local FS where the maintainers at least plan
to incorporate delegations?

            -- Eric

