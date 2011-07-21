Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45277 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753139Ab1GUQal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 12:30:41 -0400
Date: Thu, 21 Jul 2011 12:30:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/9] sunrpc: Create sockets in namespaces
Message-ID: <20110721163037.GB1114@fieldses.org>
References: <4CA32AB4.2090808@parallels.com>
 <20110720211040.GC27871@fieldses.org>
 <4E27DA40.7040207@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E27DA40.7040207@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jul 21, 2011 at 11:50:24AM +0400, Pavel Emelyanov wrote:
> On 07/21/2011 01:10 AM, J. Bruce Fields wrote:
> > Just curious--is there still work left on nfs and rpc containerization?
> > And what's left to do there?
> 
> Yes, there's still more work todo. Unfortunately it is stalled now, but
> I plan to return back to it soon. Sorry about it.

No big deal, just wondering how big what's left is; do you have a list
somewhere?

--b.
