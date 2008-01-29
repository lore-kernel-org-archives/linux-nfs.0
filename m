From: Greg Banks <gnb-pHk1y4uTXVCai2JIS6bsrQ@public.gmane.org>
Subject: Re: NFS over TCP idle timeout
Date: Tue, 29 Jan 2008 14:57:31 +1100
Message-ID: <20080129035731.GA42391370@ocelot.melbourne.sgi.com>
References: <Pine.GSO.4.55.0801251516550.21@loogie.intranet.csupomona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Paul B. Henson" <henson@acm.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:33266 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752500AbYA2D5r (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 22:57:47 -0500
In-Reply-To: <Pine.GSO.4.55.0801251516550.21-z2goPYwGszwoNljnaZt3ZkHinNCOp9DfhYY8Ac/fI6A@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 25, 2008 at 04:41:00PM -0800, Paul B. Henson wrote:
> 
> Does the Linux server implementation of NFS over TCP implement an idle
> timeout that automatically disconnects clients after some amount of
> inactivity?
>  [...]
> Should idle connections automatically be closed? Are there any tunables or
> switches that need to be touched to enable that?

Try applying this

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7a1fa065a0264f6b3d3003ba5635289f6583c478

-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.
