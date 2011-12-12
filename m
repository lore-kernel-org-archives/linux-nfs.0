Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44014 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754423Ab1LLWHQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 17:07:16 -0500
Date: Mon, 12 Dec 2011 17:07:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: John Simon <tzzhc4@yahoo.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Intermittent performance issues with Solaris 10 NFS V3 client
 to RHEL 5.5 NFS server
Message-ID: <20111212220715.GG20826@fieldses.org>
References: <20111212161348.GG18185@fieldses.org>
 <1323713796.6172.YahooMailClassic@web181402.mail.ne1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323713796.6172.YahooMailClassic@web181402.mail.ne1.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 12, 2011 at 10:16:36AM -0800, John Simon wrote:
> I had opened a case with SUN/Oracle and send trace and snoop output. Their comment was the issue was response from the Linux side.

Did they give any reason for that?

> >     - Can you get any rpc statistics out of the client?  (Average
> >     time to respond to an rpc, mix of rpc's sent, etc.?)
> 
> I need to look at rpc stats on the client.
> 
> I received a couple off list replies from other users who mentioned
> they encountered similar issues and upgrading their kernel helped (one
> user was on 5.5 and went to 5.6 and another was running Debian). If
> anyone knows of any issues with 2.6.18-194.el5 nfs-utils-1.0.9-44.el5
> that could cause intermittent performance for NFS I would appreciate
> it.

Especially if it's specific to a particular Red Hat kernel, getting Red
Hat support involved would make sense.

--b.
