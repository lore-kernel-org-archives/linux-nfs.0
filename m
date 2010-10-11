Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49854 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754315Ab0JKNWz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 09:22:55 -0400
Message-ID: <4CB30FA9.8020308@RedHat.com>
Date: Mon, 11 Oct 2010 09:22:49 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/15] libnfs.a: Allow multiple RPC listeners to share
 listener port number
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000421.6667.60700.stgit@ellison.1015granger.net> <20101011002022.GB25663@merit.edu>
In-Reply-To: <20101011002022.GB25663@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 10/10/2010 08:20 PM, Jim Rees wrote:
> Chuck Lever wrote:
> 
>   Normally, when "-p" is not specified on the mountd command line, the
>   TI-RPC library chooses random port numbers for each listener.  If a
>   port number _is_ specified on the command line, all the listeners
>   will get the same port number, so SO_REUSEADDR needs to be set on
>   each socket.
>   
>   Thus we can't let TI-RPC create the listener sockets for us in this
>   case; we must create them ourselves and then set SO_REUSEADDR (and
>   other socket options) by hand.
> 
> It bothers me that there are two separate code paths in two separate
> libraries for these two nearly identical cases.  Wouldn't it be better to
> add this functionality to tirpc?
I have to agree... Why can't we simply had the tirpc code a socket
that has the SO_REUSEADDR set on it? 

steved.
