From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFSD: Don't hold unrefcounted creds over call to	nfsd_setuser()
Date: Thu, 02 Jul 2009 09:59:42 -0400
Message-ID: <4A4CBD4E.90802@RedHat.com>
References: <20090702133532.28297.89635.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: bfields@fieldses.org, rasmus-tUP8e6pgWdNlY7y4Fx5NiA@public.gmane.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59457 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672AbZGBOD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jul 2009 10:03:56 -0400
In-Reply-To: <20090702133532.28297.89635.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/02/2009 09:35 AM, David Howells wrote:
> nfsd_open() gets an unrefcounted pointer to the current process's effective
> credentials at the top of the function, then calls nfsd_setuser() via
> fh_verify() - which may replace and destroy the current process's effective
> credentials - and then passes the unrefcounted pointer to dentry_open() - but
> the credentials may have been destroyed by this point.
> 
> Instead, the value from current_cred() should be passed directly to
> dentry_open() as one of its arguments, rather than being cached in a variable.
> 
> Possibly fh_verify() should return the creds to use.
> 
> Signed-off-by: David Howells <dhowells@redhat.com>

Tested-and-Verified-By: Steve Dickson <steved@redhat.com>
