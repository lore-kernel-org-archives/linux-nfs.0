From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Jul 22 23:53:35 serverNameNX: svc: unknown version (0 for prog
 100003 nfsd)
Date: Tue, 3 Aug 2010 15:55:00 -0400
Message-ID: <20100803195500.GF31579@fieldses.org>
References: <4C495DBA.6090600@limepepper.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom H <tom-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33857 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756326Ab0HCT4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 15:56:22 -0400
In-Reply-To: <4C495DBA.6090600-6kxvdouIZplzjhtm8Ag3mw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 23, 2010 at 10:15:38AM +0100, Tom H wrote:
> 
> Hi,
> 
> Since last week my syslog is full of these messages;
> 
> 
>  Jul 22 23:53:35 serverNameNX: svc: unknown version (0 for prog 100003
>  nfsd)
> 
> <http://serverfault.com/questions/163306/jul-22-235335-servernamexxx-svc-unknown-version-0-for-prog-100003-nfsd>
> 
> 
> I think it is since we started to monitor for rpcinfo -p serverNameNX
> remotely.

I don't see why rpcinfo -p should be sending version 0 nfsd packets.

> Any suggestions on what I can do to either understand or suppress this
> alert?

We should probably just remove it some day.

--b.
