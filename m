Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756801Ab2EBBl5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 21:41:57 -0400
Date: Tue, 1 May 2012 21:41:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steved@redhat.com
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>, NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 0/3] Fix use_ipaddr race
Message-ID: <20120502014155.GA2684@fieldses.org>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
 <20120423110419.1311c364@notabene.brown>
 <20120428112639.GA22396@fieldses.org>
 <20120428214726.1742c905@notabene.brown>
 <20120428155917.GA23348@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120428155917.GA23348@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 28, 2012 at 11:59:17AM -0400, J. Bruce Fields wrote:
> Hah.  I think I had some vague idea like "the ? reminds us there's still
> some question to be answered about this".  Anyway, my one worry is that
> I'm not sure what the syntax of the existing client types.
> 
> Hm, the documentation says "?" and "[character set]" can be used in
> wildcard domains, so maybe we do want '!' or '$'.

OK, going with '$', and also fixing a logic error found in testing, I
get the following.

I've done simple mounts but *haven't* actually tested the use_ipaddr
case; I'll report results when I get them.

It might be reasonable to go ahead and apply them anyway; up to you.

--b.
