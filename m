From: Nix <nix@esperi.org.uk>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often fails to delete things it just created
Date: Sun, 18 Apr 2010 21:03:43 +0100
Message-ID: <87mxx0a5pc.fsf@spindle.srvr.nix>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	<1271618484.8049.1.camel@localhost.localdomain>
	<87vdboa7e0.fsf@spindle.srvr.nix>
	<1271620750.8049.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:38811 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757591Ab0DRUDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Apr 2010 16:03:49 -0400
In-Reply-To: <1271620750.8049.3.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org> (Trond Myklebust's message of "Sun, 18 Apr 2010 15:59:10 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Apr 2010, Trond Myklebust said:

> On Sun, 2010-04-18 at 20:27 +0100, Nix wrote: 
>> On 18 Apr 2010, Trond Myklebust verbalised:
>> tip-of-tree includes that commit, and it's still happening for me there.
>> (Just verified again.)
>
> Does a 'sync' clear out the sillyrenamed files?

Yes.
