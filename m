Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:34211 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbeEJVPu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 May 2018 17:15:50 -0400
Date: Thu, 10 May 2018 21:15:46 +0000
From: Vallish Vaidyeshwara <vallish@amazon.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "jsstraus@amazon.com" <jsstraus@amazon.com>
Subject: Re: [PATCH 2/2] SUNRPC: Reconnect with new port on server initiated
 connection termination
Message-ID: <20180510211546.GB50901@amazon.com>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
 <1525932774-98736-3-git-send-email-vallish@amazon.com>
 <aa092f62079986ec164863f33873b278f69f79a9.camel@hammerspace.com>
 <20180510162202.GA24317@amazon.com> <20180510173728.GA3736@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <20180510173728.GA3736@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 01:37:28PM -0400, bfields@fieldses.org wrote:
> On Thu, May 10, 2018 at 04:22:02PM +0000, Vallish Vaidyeshwara wrote:
> > If the server has closed a connection, then no DRC state remains on the server
> > we want to use.
> 
> That's not a rule, as far as I know.  Certainly the Linux server doesn't
> destroy DRC state on closing a connection.  (Should it? I'm not sure
> that's a good idea.)
> 
> --b.
> 

Thanks for the clarification and I agree patch 2 should not be applied.
