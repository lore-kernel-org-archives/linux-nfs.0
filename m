From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.34rc4 NFS writeback regression (bisected): client often
 fails to delete things it just created
Date: Sun, 18 Apr 2010 16:13:44 -0400
Message-ID: <1271621624.8049.6.camel@localhost.localdomain>
References: <87tyr9dfvv.fsf@spindle.srvr.nix>
	 <1271618484.8049.1.camel@localhost.localdomain>
	 <87vdboa7e0.fsf@spindle.srvr.nix>
	 <1271620750.8049.3.camel@localhost.localdomain>
	 <87mxx0a5pc.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Nix <nix@esperi.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:43651 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529Ab0DRUNu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 18 Apr 2010 16:13:50 -0400
In-Reply-To: <87mxx0a5pc.fsf-AdTWujXS48Mg67Zj9sPl2A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2010-04-18 at 21:03 +0100, Nix wrote: 
> On 18 Apr 2010, Trond Myklebust said:
> 
> > On Sun, 2010-04-18 at 20:27 +0100, Nix wrote: 
> >> On 18 Apr 2010, Trond Myklebust verbalised:
> >> tip-of-tree includes that commit, and it's still happening for me there.
> >> (Just verified again.)
> >
> > Does a 'sync' clear out the sillyrenamed files?
> 
> Yes.

OK. Next question is how these files are being written. If you 'strace'
the process, do you see ordinary write() calls being used, or is the
file perhaps being written via mmap()?

