Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57680 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966631AbeEJRh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 May 2018 13:37:28 -0400
Date: Thu, 10 May 2018 13:37:28 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Vallish Vaidyeshwara <vallish@amazon.com>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "jsstraus@amazon.com" <jsstraus@amazon.com>
Subject: Re: [PATCH 2/2] SUNRPC: Reconnect with new port on server initiated
 connection termination
Message-ID: <20180510173728.GA3736@fieldses.org>
References: <1525932774-98736-1-git-send-email-vallish@amazon.com>
 <1525932774-98736-3-git-send-email-vallish@amazon.com>
 <aa092f62079986ec164863f33873b278f69f79a9.camel@hammerspace.com>
 <20180510162202.GA24317@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180510162202.GA24317@amazon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2018 at 04:22:02PM +0000, Vallish Vaidyeshwara wrote:
> If the server has closed a connection, then no DRC state remains on the server
> we want to use.

That's not a rule, as far as I know.  Certainly the Linux server doesn't
destroy DRC state on closing a connection.  (Should it? I'm not sure
that's a good idea.)

--b.
