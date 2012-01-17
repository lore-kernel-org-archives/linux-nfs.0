Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e38.co.us.ibm.com ([32.97.110.159]:48949 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab2AQRWx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2012 12:22:53 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 17 Jan 2012 10:22:52 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id BF72219D804B
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 10:22:45 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0HHMXqh096922
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 10:22:34 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0HHMWLH002451
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 10:22:33 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0HHMVis002342
	for <linux-nfs@vger.kernel.org>; Tue, 17 Jan 2012 10:22:31 -0700
Date: Tue, 17 Jan 2012 11:22:31 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120117172231.GA21603@us.ibm.com>
References: <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
 <20120114013834.GA20464@fieldses.org>
 <20120116165228.GA4990@us.ibm.com>
 <20120117151826.GB12274@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117151826.GB12274@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> > Only answers can be dumb! Bruce, we have ext3/ext4 file systems on two
> > separate servers. The file systems are mirrored using rsync as and when
> > needed. We would like to use the servers as replicas.
> 
> And why aren't you rsync'ing the underlying filesystem image instead?
> Is that too slow?

The file system image is too big to do entire image level rsync'ing.

> > Since the file systems are mirrored using "rsync", the NFS file handles
> > each server exports would be different. We would like to use volatile
> > file handles feature of NFSv4 for this.
> 
> In theory the hidden directory for reverse lookups would work, but it
> seems like it would be complicated to get right:
> 	- How do you generate the directory and keep it up to date?
> 	- What happens if somebody breaks the rules and updates the
> 	  filesystem while it's being exported?

I think so too. We think Volatile file handle support on the client side
is simpler for our use case (read only NFS file systems)

Regards, Malahal.

