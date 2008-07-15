From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: eliminate duplicate calls to nlmsvc_lookup_host
	in nlmsvc_lock and nlmsvc_testlock
Date: Tue, 15 Jul 2008 14:45:54 -0400
Message-ID: <20080715184554.GD21590@fieldses.org>
References: <1215868630-28201-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39547 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753454AbYGOSqL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 14:46:11 -0400
In-Reply-To: <1215868630-28201-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 12, 2008 at 09:17:10AM -0400, Jeff Layton wrote:
> Both nlmsvc_lock and nlmsvc_testlock call nlmsvc_lookup_host to find a
> nlm_host struct. All the callers of these functions, however, call
> nlmsvc_retrieve_args or nlm4svc_retrieve_args which also return a
> nlm_host struct.
> 
> Change nlmsvc_lock and nlmsvc_testlock to take a host arg instead of
> calling nlmsvc_lookup_host themselves and change the callers to pass
> a pointer to the nlm_host they've already found.

That makes sense to me, thanks.

> Also, get rid of some unneeded nlm_host NULL checks.
> 
> I think I've got the reference counting right with this patch, but
> I wouldn't mind someone sanity checking it.

So, the way I do that sanity-checking is by breaking up the individual
changes as finely as I can, as follows....

--b.
