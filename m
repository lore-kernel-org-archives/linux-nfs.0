From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 08 Mar 2010 13:30:23 -0500
Message-ID: <4B95423F.6070805@oracle.com>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu> <1267992481-13332-3-git-send-email-bfields@citi.umich.edu> <20100308082516.260e5f70@notabene.brown> <20100307215826.GA14104@fieldses.org> <20100308101014.14e635b2@notabene.brown> <20100308182148.GB1675@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:56782 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab0CHScl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Mar 2010 13:32:41 -0500
In-Reply-To: <20100308182148.GB1675@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/08/2010 01:21 PM, J. Bruce Fields wrote:
> Occasionally we seem to hear from a security-conscious administrator
> who's running v4-only and is irritated that they have to firewall off
> mountd instead of just being able to kill it entirely.  The latter might
> reassure them, I suppose.

I think Jeff had the idea of having mountd simply not set up its RPC 
listeners in that case.  That looks easy to do.

-- 
chuck[dot]lever[at]oracle[dot]com
