Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:51393 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760784Ab3DBSxp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 14:53:45 -0400
Date: Tue, 2 Apr 2013 14:53:38 -0400
From: Jim Rees <rees@umich.edu>
To: Simo Sorce <simo@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
Message-ID: <20130402185337.GC18900@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
 <20130402150049.GA526@umich.edu>
 <1364919975.2660.1255.camel@willson.li.ssimo.org>
 <20130402164631.GA23840@umich.edu>
 <1364922203.2660.1265.camel@willson.li.ssimo.org>
 <20130402183907.GB18900@umich.edu>
 <1364928519.2660.1279.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364928519.2660.1279.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce wrote:

  >  And stop using the term "mitm". A mitm attack is used to
  > convince both ends of a connection that they are talking to each other. DNS
  > is not a mutually authenticated exchange.
  
  Well it is still a sort of Man in the Middle, as you also have to
  redirect communications (nfsv4 uses TCP) for it to be effective, it is
  just not exploiting a crypto issue.

Now you've lost me again. I thought we were discussing dns. What does nfs
have to do with it?
