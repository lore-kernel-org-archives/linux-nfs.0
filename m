Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32155 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097Ab2GLWFY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jul 2012 18:05:24 -0400
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
In-Reply-To: <20120712123916.GB16822@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
	 <20120710204913.GA6038@fieldses.org> <20120710210511.GB6038@fieldses.org>
	 <20120712123916.GB16822@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 Jul 2012 18:05:17 -0400
Message-ID: <1342130717.2718.32.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-07-12 at 08:39 -0400, J. Bruce Fields wrote:
> And this is reproduceable after applying the first patch
> ("conditionally
> return endtime...") but not before.  The patch seems obviously
> innocent,
> but maybe my eyes are playing tricks on me.
> 
missing braces around the if statement where I inserted the if (endtime)
contion, causing instead to always kfree(ctx)

Sorry about that, it completely escaped my review of it multiple times
over.

SImo.

-- 
Simo Sorce * Red Hat, Inc * New York

