From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often fails to delete things it just created
Date: Mon, 19 Apr 2010 19:54:41 +0100
Message-ID: <87aasz9ssu.fsf@spindle.srvr.nix>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	<1271618484.8049.1.camel@localhost.localdomain>
	<87vdboa7e0.fsf@spindle.srvr.nix>
	<1271620750.8049.3.camel@localhost.localdomain>
	<87mxx0a5pc.fsf@spindle.srvr.nix>
	<1271621624.8049.6.camel@localhost.localdomain>
	<87iq7oa2o8.fsf@spindle.srvr.nix>
	<1271682635.13653.40.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:59515 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab0DSSys (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 14:54:48 -0400
In-Reply-To: <1271682635.13653.40.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Trond Myklebust's message of "Mon, 19 Apr 2010 09:10:35 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 19 Apr 2010, Trond Myklebust verbalised:
> Hmm... Could you please try reverting commit
> 2c61be0a9478258f77b66208a0c4b1f5f8161c3c (NFS: Ensure that the WRITE and
> COMMIT RPC calls are always uninterruptible). I wonder if that
> introduced a new race...

That seems to have fixed it.

(This must be a heck of a wide race, or I'm very unlucky :) I hit it
every single time, even if the machine is under heavy load...)
