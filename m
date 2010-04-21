From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often fails to delete things it just created
Date: Wed, 21 Apr 2010 23:13:23 +0100
Message-ID: <87tyr4fo8s.fsf@spindle.srvr.nix>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	<1271618484.8049.1.camel@localhost.localdomain>
	<87vdboa7e0.fsf@spindle.srvr.nix>
	<1271620750.8049.3.camel@localhost.localdomain>
	<87mxx0a5pc.fsf@spindle.srvr.nix>
	<1271621624.8049.6.camel@localhost.localdomain>
	<87iq7oa2o8.fsf@spindle.srvr.nix>
	<1271682635.13653.40.camel@localhost.localdomain>
	<87aasz9ssu.fsf@spindle.srvr.nix>
	<1271767064.25129.84.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:33573 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754602Ab0DUWOS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 18:14:18 -0400
In-Reply-To: <1271767064.25129.84.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Trond Myklebust's message of "Tue, 20 Apr 2010 08:37:44 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 Apr 2010, Trond Myklebust uttered the following:
> I therefore think we need something like the following patch.

I tried three cmakes in succession: the problem, at least in this
manifestation, appears to be gone.

Thanks for the fix! (Races are always horrible: it's impressive to me
that you diagnosed it correctly first time...)
