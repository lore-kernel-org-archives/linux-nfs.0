From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Thu, 27 Mar 2008 16:57:20 -0400
Message-ID: <1206651440.15396.20.camel@heimdal.trondhjem.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
	 <20080327195445.GI32540@fieldses.org>
	 <1206648229.15396.2.camel@heimdal.trondhjem.org>
	 <20080327202331.GJ32540@fieldses.org>
	 <EXNANE01kO22ZhCl8ai000001cd@exnane01.hq.netapp.com>
	 <20080327205311.GL32540@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Olga Kornievskaia <aglo@umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3797 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756328AbYC0U53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 16:57:29 -0400
In-Reply-To: <20080327205311.GL32540@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-27 at 16:53 -0400, J. Bruce Fields wrote:
> (Though
> perhaps it could be useful to the administrator to have some optional
> way to figure out the callback status if they were e.g. investigating a
> performance problem.)

Well, we have dprintk(), but at some point in the near future, I'd like
to check out the kernel markers functionality to see if we can't start
replacing the existing dprintk()s with something a bit more targeted.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
