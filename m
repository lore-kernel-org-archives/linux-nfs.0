Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbcHCR76 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 13:59:58 -0400
Subject: Re: [PATCH 6/7] mountd: allow alternate ttl to be specified for
 dump_to_cache.
To: NeilBrown <neilb@suse.com>
References: <146976807524.20186.8871903418718212567.stgit@noble>
 <146976861681.20186.16926967483251671716.stgit@noble>
 <b4e08e92-9f58-967b-73cd-4785e4fb17c7@RedHat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <f1a91958-edf7-5187-e662-78df55228045@RedHat.com>
Date: Wed, 3 Aug 2016 13:59:57 -0400
MIME-Version: 1.0
In-Reply-To: <b4e08e92-9f58-967b-73cd-4785e4fb17c7@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/03/2016 01:31 PM, Steve Dickson wrote:
> Hey Neil,
> 
> This one is a bit confusing... Unless I'm missing something this
> patch enables the passing of the TTL in to dump_to_cache() but
> a zero is always passed in which causes the default TTL to
> be used... So I guess my question is... what's the point?
> Is there an upcoming patch that will  actually passing a 
> non-default TTL

Never mind... I see how its used in patch 7..

Sorry for the noise.

steved.
