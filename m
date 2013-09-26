Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134Ab3IZP1t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 11:27:49 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130926152125.GD704@fieldses.org>
References: <20130926152125.GD704@fieldses.org> <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com, olof@lixom.net,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC][PATCH 0/4] SunRPC/NFS: Use no_printk() in
Date: Thu, 26 Sep 2013 16:27:39 +0100
Message-ID: <30413.1380209259@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@fieldses.org> wrote:

> > Here's a series of patches to make SunRPC/NFS use no_printk() to implement
> > its null dfprintk() macro (ie. when RPC_DEBUG is disabled).  This prevents
> > 'unused variable' errors from occurring when a variable is set only for
> > use in debugging statements and renders RPC/NFS_IFDEBUG unnecessary.
> 
> Does this patch series fix any actual warnings?  Or does it just change
> the way that we prevent the warnings?

It fixes some unused variable warnings introduced by NFS FS-Cache patches that
I have (a variable is set up and only passed to dfprintk() a couple of times).

I could change those patches to do something different, but I think changing
dfprintk() is actually the right solution as it will catch errors introduced
into dfprintk() calls that are currently reduced to do{}while(0) by the
preprocessor rather than letting the compiler chew on them and then reducing
them to nothing with the optimiser.

David
