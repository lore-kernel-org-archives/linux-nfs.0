From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] rpc: remove unneeded function parameter in
 gss_add_msg()
Date: Wed, 09 Dec 2009 15:18:38 -0500
Message-ID: <1260389918.2646.2.camel@localhost>
References: <1260380722-7599-1-git-send-email-sjayaraman@suse.de>
	 <20091209185733.GC23234@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Suresh Jayaraman <sjayaraman@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:45257 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752595AbZLIUSd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2009 15:18:33 -0500
In-Reply-To: <20091209185733.GC23234@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-12-09 at 13:57 -0500, J. Bruce Fields wrote: 
> On Wed, Dec 09, 2009 at 11:15:22PM +0530, Suresh Jayaraman wrote:
> > The pointer to struct gss_auth parameter in gss_add_msg is not really needed
> > after commit 5b7ddd4a. Zap it.
> 
> Looks straightforward to me, thanks.  (Assuming Trond will take it.)

Yes. I'll pick it up...

Trond
