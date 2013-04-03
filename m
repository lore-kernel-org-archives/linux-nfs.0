Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41893 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173Ab3DCSUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 14:20:04 -0400
Date: Wed, 3 Apr 2013 14:20:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>, Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130403182001.GB6044@fieldses.org>
References: <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
 <20130402183907.GB18900@umich.edu>
 <1364928519.2660.1279.camel@willson.li.ssimo.org>
 <20130403134407.GB13951@fieldses.org>
 <20130403144055.GA7049@umich.edu>
 <1365005018.2660.1315.camel@willson.li.ssimo.org>
 <20130403171213.GB3344@fieldses.org>
 <1365012777.2660.1317.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1365012777.2660.1317.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 03, 2013 at 02:12:57PM -0400, Simo Sorce wrote:
> Yup, ok.
> 
> So if anyone can ack the actual patches (or tell me if there is anything
> else to change I'd love to move forward, I have other patches in the
> pipeline :-)

Look fine to me; I didn't have any objection outside documentation.

I've lost track of which are the latest patches, honestly--hopefully
Steve's been keeping track, it's up to him to merge them.

--b.
