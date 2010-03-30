From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs: server not responding, timed out
Date: Tue, 30 Mar 2010 10:44:38 -0400
Message-ID: <20100330144438.GE11545@fieldses.org>
References: <20100318170603.f6a7f188.dennisn@dennisn.dyndns.org> <4BA2DFC5.1010400@cn.fujitsu.com> <20100319002720.0e93411e.dennisn@dennisn.dyndns.org> <20100319181038.c94fa3c4.dennisn@dennisn.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Dennis Nezic <dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44738 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756427Ab0C3Oma (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Mar 2010 10:42:30 -0400
In-Reply-To: <20100319181038.c94fa3c4.dennisn-YN8wfZw00oOZ9vWoFJJngh2eb7JE58TQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 19, 2010 at 06:10:38PM -0400, Dennis Nezic wrote:
> On Fri, 19 Mar 2010 00:27:20 -0400, Dennis Nezic wrote:
> > 
> > Both the patches mentioned in that thread already seem to have been
> > applied to my kernels. So, although the problem seems related, it
> > wasn't that bug in particular. The person in that thread was talking
> > about mounts dying after 5-15minutes, which doesn't happen with me --
> > my problem only seems to occur under intense activity.
> 
> Hrm. I just noticed that my scp transfers are stalling -- which also
> didn't used to happen before with my old kernel. No error messages. Ftp
> transfers work fine. Eek. :S. (Despite the freezing/stalling, my
> *actual* network connection works perfectly.)

That also suggests some network problem....  Is the scp problem
reproduceable?  Are packets getting dropped?

Also: is the kernel dumping any backtraces into the server's logs?

--b.
