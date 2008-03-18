From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: asynchronous destroy messages
Date: Tue, 18 Mar 2008 18:32:12 -0400
Message-ID: <20080318223212.GA12362@fieldses.org>
References: <20080318221515.GE29948@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, aglo@citi.umich.edu
To: Trond Myklebust <trond@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39770 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964989AbYCSWcb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Mar 2008 18:32:31 -0400
In-Reply-To: <20080318221515.GE29948@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 18, 2008 at 06:15:15PM -0400, bfields wrote:
> When an rpc client is shut down, gss destroy messages are sent out
> asynchronously, and nobody waits for them.
> 
> If those rpc messages arrive after the client is completely shut down, I
> assume they just get dropped by the networking code?  Is it possible for
> them to arrive while we're still in the process of shutting down, and if
> so, what makes this safe?

In other words--when does the task that's created to send the destroy
message get freed, and if that doesn't happen till after the rpc client
and associated objects are freed, is there a risk of someone trying to
access those objects through fields in that task?

--b.

> 
> Olga's seeing some odd oopses on shutdown after testing our gss callback
> code.  And of course it's probably our callback patches at fault, but I
> was starting to wonder if there was a problem with those destroy
> messages arriving at the wrong moment.  Any pointers welcomed.
> 
> --b.
