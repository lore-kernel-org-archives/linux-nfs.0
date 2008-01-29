From: "Paul B. Henson" <henson@acm.org>
Subject: Re: NFS over TCP idle timeout
Date: Tue, 29 Jan 2008 13:53:50 -0800 (PST)
Message-ID: <Pine.GSO.4.55.0801291346440.15248@loogie.intranet.csupomona.edu>
References: <Pine.GSO.4.55.0801251516550.21@loogie.intranet.csupomona.edu>
 <20080129035731.GA42391370@ocelot.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Greg Banks <gnb-pHk1y4uTXVCai2JIS6bsrQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sparky.unx.csupomona.edu ([134.71.247.19]:43587 "EHLO
	sparky.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322AbYA2Vxy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 16:53:54 -0500
In-Reply-To: <20080129035731.GA42391370-WP8ATAqLPZFHNW7Ns3LnmGRHvnxUvMa2@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 29 Jan 2008, Greg Banks wrote:

> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7a1fa065a0264f6b3d3003ba5635289f6583c478

Ah, yes, the 2.6.20 kernel I am currently running does have the change from
aaf68cfbf2241d24d46583423f6bff5c47e088b3 introducing the bias to sk_inuse.
This is probably the problem I am running into. The 2.6.23 kernel I will be
upgrading to within a week or two appears to have this fix already applied,
so hopefully that upgrade will resolve my issue.

Thanks much for the information...


-- 
Paul B. Henson  |  (909) 979-6361  |  http://www.csupomona.edu/~henson/
Operating Systems and Network Analyst  |  henson@csupomona.edu
California State Polytechnic University  |  Pomona CA 91768
