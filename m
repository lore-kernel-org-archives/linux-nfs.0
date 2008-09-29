From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs(5): Replace the term "netid" in mount option descriptions
Date: Mon, 29 Sep 2008 07:53:43 -0400
Message-ID: <48E0C1C7.4060201@RedHat.com>
References: <20080924182235.3000.71437.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: mike.eisler@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48508 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbYI2LzR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 07:55:17 -0400
In-Reply-To: <20080924182235.3000.71437.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> TI-RPC introduced the concept of "netid" which is a string that is
> mapped to a set of transport capabilities via a netconfig database.
> RPC services register a netid and bindaddr with their local rpcbind
> daemon to advertise their ability to support particular transports.
> 
> Mike Eisler noted that the use of the term "netid" in nfs(5) is not
> appropriate, since Linux does not treat the value of the proto= or
> mountproto= options as a netid proper, but rather to select a
> particular transport capability provided locally on the client.
> 
> The Linux NFS client currently uses a simple internal mapping between
> these names and its own transport capabilities rather than using the
> names as part of an rpcbind query, thus these strings are really not
> netids.  They are more akin to what TI-RPC calls "protocol names".
> 
> Remove the term "netid" from nfs(5) for now.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Cc: Mike Eisler <mike.eisler@netapp.com>
Committed... 

steved.
