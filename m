Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760022Ab3DBTCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 15:02:45 -0400
Subject: Re: [PATCH] Avoid PTR lookups when possible
From: Simo Sorce <simo@redhat.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, Steve Dickson <steved@redhat.com>,
        Jeffrey Layton <jlayton@redhat.com>
In-Reply-To: <20130402185337.GC18900@umich.edu>
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
	 <20130402150049.GA526@umich.edu>
	 <1364919975.2660.1255.camel@willson.li.ssimo.org>
	 <20130402164631.GA23840@umich.edu>
	 <1364922203.2660.1265.camel@willson.li.ssimo.org>
	 <20130402183907.GB18900@umich.edu>
	 <1364928519.2660.1279.camel@willson.li.ssimo.org>
	 <20130402185337.GC18900@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Apr 2013 15:02:38 -0400
Message-ID: <1364929358.2660.1280.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-04-02 at 14:53 -0400, Jim Rees wrote:
> Simo Sorce wrote:
> 
>   >  And stop using the term "mitm". A mitm attack is used to
>   > convince both ends of a connection that they are talking to each other. DNS
>   > is not a mutually authenticated exchange.
>   
>   Well it is still a sort of Man in the Middle, as you also have to
>   redirect communications (nfsv4 uses TCP) for it to be effective, it is
>   just not exploiting a crypto issue.
> 
> Now you've lost me again. I thought we were discussing dns. What does nfs
> have to do with it?

It's complicated, but if you re-read the scenario I wrote and think how
the rpcgss communication happens you should see it.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

