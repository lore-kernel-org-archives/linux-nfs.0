From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] NFSD: Don't hold unrefcounted creds over call to nfsd_setuser()
Date: Thu, 02 Jul 2009 22:31:33 +0100
Message-ID: <575.1246570293@redhat.com>
References: <20090702203937.GA10504@fieldses.org> <20090702133532.28297.89635.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, steved@redhat.com, rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36594 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480AbZGBVbh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jul 2009 17:31:37 -0400
In-Reply-To: <20090702203937.GA10504@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> Got it, thanks.  How easy is it to hit this case?  (Just wondering
> whether to submit for stable.)

Actually, one of the problems with it is that the file is opened using the old
creds, cached across the call to nfsd_setuser().

David
