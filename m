From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: Set address family before calling
	nlm_host_rebooted()
Date: Fri, 31 Oct 2008 13:46:57 -0400
Message-ID: <20081031174657.GB8955@fieldses.org>
References: <20081023044245.15258.55293.stgit@ingres.1015granger.net> <20081023205820.GB26419@fieldses.org> <BF3BC6B3-D58F-43B1-AACD-284DDFA291DC@ORACLE.COM> <20081030212856.GB24156@fieldses.org> <A34BAC35-D8FB-4DD2-8A1F-6780FD0914C5@ORACLE.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59965 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750753AbYJaRq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2008 13:46:58 -0400
In-Reply-To: <A34BAC35-D8FB-4DD2-8A1F-6780FD0914C5-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 31, 2008 at 01:39:29PM -0400, Chuck Lever wrote:
> I tested a 2.6.28-rc2 kernel on the server side with and without the  
> fix.  I rebooted the client with "echo b > /proc/sysrq_trigger" for this 
> test.
>
> If the server doesn't have the fix, I see the "never saw host x.x.x.x"  
> message on the server after the client reboots.  If the fix is applied, I 
> see the "nlm_host_rebooted (x.x.x.x)" message on the server after the 
> client reboots.
>
> So, confirmed that this is a bug in 2.6.28-rc2, and confirmed that the  
> below patch addresses the problem.  The NSM logic is the same on the  
> client and the server, so I didn't test a server reboot.

Excellent, thanks very much!

(Though for the future as a regular regression test from a script, I
think we'd want to test for a lock after reboot with a GETLK rather than
looking for dprintk's in the logs.)

--b.
