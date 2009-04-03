From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in
 create_auth_rpc_client unless we need port
Date: Fri, 3 Apr 2009 15:04:15 -0400
Message-ID: <20090403150415.3586bba3@tleilax.poochiereds.net>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-4-git-send-email-jlayton@redhat.com>
	<F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
	<20090401134739.01b72029@barsoom.rdu.redhat.com>
	<32D01620-325D-4D82-81EF-8584134BC7DC@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, kwc@citi.umich.edu
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49912 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757479AbZDCTEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Apr 2009 15:04:25 -0400
In-Reply-To: <32D01620-325D-4D82-81EF-8584134BC7DC@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 1 Apr 2009 14:01:30 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> As far as I understand it, the ai_socktype and ai_protocol fields are  
> used to return the values needed for subsequent socket(2)/bind(2)  
> system calls.  In this case you are not using these fields from the  
> results...
> 
> If ai_protocol is zero, then getaddrinfo(3) assumes you want one copy  
> of the address for each supported protocol type, so it returns three  
> structures (one for IPPROTO_UDP, one for IPPROTO_TCP, and one with a  
> zero protocol number).  The contents, except for the socktype and  
> protocol fields, are the same for each.
> 

Hypothetical situation...

Suppose there is a service in /etc/services that has a different port
number for tcp than for udp:

fooserv		50001/tcp
fooserv		50002/udp

You're saying that getaddrinfo will return the same port number in all
of the returned structures? Won't that mean that one of the port numbers
is wrong? That seems broken if so...

If that's not the case, then I think we need to at least set the
ai_protocol in the hints.

-- 
Jeff Layton <jlayton@redhat.com>
