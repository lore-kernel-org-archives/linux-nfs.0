From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] silence-call-timeout-printk
Date: Thu, 27 Mar 2008 16:03:49 -0400
Message-ID: <1206648229.15396.2.camel@heimdal.trondhjem.org>
References: <1206643752-11132-1-git-send-email-aglo@umich.edu>
	 <20080327195445.GI32540@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15675 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756940AbYC0UDw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Mar 2008 16:03:52 -0400
In-Reply-To: <20080327195445.GI32540@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-03-27 at 15:54 -0400, J. Bruce Fields wrote:
> On Thu, Mar 27, 2008 at 02:49:12PM -0400, Olga Kornievskaia wrote:
> > When the client's callback server goes away, the server's callback client
> > tries to contact the server and times out. For nfsd, it is beneficial to
> > printout a message when the client is unable to contact the server. For
> > the callback server, the same message is printed yet it is really not
> > an error. Thus we need a way to silence the message for the callback 
> > and yet print it for other cases.

Bring, back,
Bring, back,
Oh, bring back my cl_chatty to me...

  http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=f518e35aec984036903c1003e867f833747a9d79

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
