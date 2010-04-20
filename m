From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often fails to delete things it just created
Date: Tue, 20 Apr 2010 23:19:35 +0100
Message-ID: <8739yphimg.fsf@spindle.srvr.nix>
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
Received: from icebox.esperi.org.uk ([81.187.191.129]:33586 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab0DTWTr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 18:19:47 -0400
In-Reply-To: <1271767064.25129.84.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Trond Myklebust's message of "Tue, 20 Apr 2010 08:37:44 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 20 Apr 2010, Trond Myklebust spake thusly:
> I therefore think we need something like the following patch.

OK. It'll be 24 hours before I can test this, I'm afraid (real life
intervenes).
