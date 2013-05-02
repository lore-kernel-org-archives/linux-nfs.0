Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18060 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752463Ab3EBMIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 08:08:54 -0400
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: NeilBrown <neilb@suse.de>, Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20130502055625.GA11376@umich.edu>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
	 <20130502131332.5c0ce2b0@notabene.brown> <20130502055625.GA11376@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 02 May 2013 08:08:47 -0400
Message-ID: <1367496527.2976.30.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-05-02 at 01:56 -0400, Jim Rees wrote:
> I really disliked the man page wording in the original patch. Yours is much
> better.

I agree the man page wording is much better +1

> Note that it's possible to have a fqdn with no dots in it, but I expect this
> will never happen.

A FQDN with no dots in it is a top level domain name, it is extremely
unlikely you will have a NFS server that uses a TLD as name although
theoretically possible :-)

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

