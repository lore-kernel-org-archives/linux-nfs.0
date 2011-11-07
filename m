Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:47768 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932618Ab1KGRVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 12:21:39 -0500
Date: Mon, 7 Nov 2011 12:21:31 -0500
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpcbind -h
Message-ID: <20111107172131.GA1008@umich.edu>
References: <20111106155844.GA1790@umich.edu>
 <3096DDEC-48D3-423A-B674-160B8DA59DE2@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <3096DDEC-48D3-423A-B674-160B8DA59DE2@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:

  On Nov 6, 2011, at 10:58 AM, Jim Rees wrote:
  
  > Is there some good reason why the rpcbind '-h' option (bind to given
  > address) applies only to the udp listening socket and not to the tcp socket?
  
  Yes.  See the mail archives.  I believe we've discussed this thoroughly
  within the past six months to a year.  If there's any bug here, it's that
  "-h" is not well documented.

It's documented well enough but I'm still in the dark about the reason.  I
don't recall the discussion and can't find it in the archives.  The search
box on spinics isn't working for me, it returns results from the entire web,
not just the list archive.

As I said before, I was hoping for the equivalent of "portmap -l".  I was
ready to code up a patch of some kind but now have a workaround (mount with
nolock and don't run rpcbind at all).
