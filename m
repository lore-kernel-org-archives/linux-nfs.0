Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51077 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962Ab2D1L0l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 07:26:41 -0400
Date: Sat, 28 Apr 2012 07:26:39 -0400
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] Fix use_ipaddr race
Message-ID: <20120428112639.GA22396@fieldses.org>
References: <1334961978-2843-1-git-send-email-bfields@redhat.com>
 <20120423110419.1311c364@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120423110419.1311c364@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 23, 2012 at 11:04:19AM +1000, NeilBrown wrote:
> On Fri, 20 Apr 2012 18:46:15 -0400 "J. Bruce Fields" <bfields@redhat.com>
> wrote:
> 
> >   mountd: unconditionally resolve ip address
> 
> Not a good idea.  If /etc/exports only contains IP address and subnets, then
> we don't ever want to do any address resolution.  The "resolve ip address"
> must at least be conditional on "are there any domain-name, wild-cards,
> netgroups in /etc/exports".

The bug is my changelog.  All we're really doing there is parsing the ip
address, not resolving anything.

...
> >   mountd: ignore use_ipaddr and just try both client types
> 
> Maybe ... though if we could syntactically distinguish "use_ipaddr" domains
> from "!use_ipaddr" domain and still just choose one test to perform, I think
> I'd prefer that.

Hm, OK.  Something like the following?  (Totally untested.)

--b.
