From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: PROBLEM: NULL pointer dereference in rpcauth_refreshcred
Date: Sun, 24 Oct 2010 17:29:21 -0400
Message-ID: <1287955761.2915.1.camel@heimdal.trondhjem.org>
References: <3DE04C32-0B15-4BBF-A541-27152D3EC69B@mars.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Rob Leslie <rob-O+g/SLjAo04@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757067Ab0JXV31 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Oct 2010 17:29:27 -0400
In-Reply-To: <3DE04C32-0B15-4BBF-A541-27152D3EC69B-O+g/SLjAo04@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2010-10-23 at 14:50 -0700, Rob Leslie wrote:
> [1.] One line summary of the problem:
> 
> NULL pointer dereference in rpcauth_refreshcred

Hi Rob,

I suspect the following one-line patch should fix the problem.

Cheers
  Trond
------------------------------------------------------------------------------------------------------
