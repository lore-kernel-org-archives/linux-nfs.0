Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43606 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756178Ab3DRTXl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Apr 2013 15:23:41 -0400
Date: Thu, 18 Apr 2013 15:23:39 -0400
To: Stijn De Weirdt <stijn.deweirdt@ugent.be>
Cc: linux-nfs@vger.kernel.org
Subject: Re: replicas and client support
Message-ID: <20130418192339.GC31075@fieldses.org>
References: <516C2024.9030504@ugent.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <516C2024.9030504@ugent.be>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 15, 2013 at 05:43:32PM +0200, Stijn De Weirdt wrote:
> (pls keep me in cc, i'm not subscribed to this list)
> 
> i am trying out the replicas feature of exportfs, but i'm unable to
> get it working.
> 
> i would like to know if what i'm trying to is actually implemented
> in linux (or intended behaviour of replicas in the first place).
> 
> 2 nfs4 servers with cluster filesystem (gpfs in my case). the os is
> sl6.4, i've enabled the nfs version 4.1 on the server (from my
> understanding, 4.0 should be enough?).
> 
> i would like to test if the replicas features can be used for
> failover support of a rw nfs export. ie
> a. mount nfs from server1 on client
> b. start some IO activity on client on the mounted filesystem
> c. poweroff server1
> d. after a certain amount of time, IO continues using server2
> 
> (the client i'm testing with is also el6.4 atm.)

No, the client has no support I'm aware of for failover to replicas.

--b.
