Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187Ab1KFRPo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Nov 2011 12:15:44 -0500
Message-ID: <1320599727.26609.0.camel@lade.trondhjem.org>
Subject: Re: rpcbind -h
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Date: Sun, 06 Nov 2011 12:15:27 -0500
In-Reply-To: <20111106155844.GA1790@umich.edu>
References: <20111106155844.GA1790@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2011-11-06 at 10:58 -0500, Jim Rees wrote: 
> Is there some good reason why the rpcbind '-h' option (bind to given
> address) applies only to the udp listening socket and not to the tcp socket?
> 
> And is there any good reason why an nfs3 client not providing any services
> would need to run rpcbind?

Yes: lockd and statd...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

