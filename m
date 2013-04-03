Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:54246 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758541Ab3DCOlA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 10:41:00 -0400
Date: Wed, 3 Apr 2013 10:40:55 -0400
From: Jim Rees <rees@umich.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simo Sorce <simo@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>, Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130403144055.GA7049@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
 <20130402183907.GB18900@umich.edu>
 <1364928519.2660.1279.camel@willson.li.ssimo.org>
 <20130403134407.GB13951@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130403134407.GB13951@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

  Like Jim I don't understand how that fits the definition of a "man in
  the middle" attack.

If Bruce is having trouble too, I think the explanation needs to be
improved. But I think the latest patch set drops the talk about a
vulnerability, and I'm fine with that.
