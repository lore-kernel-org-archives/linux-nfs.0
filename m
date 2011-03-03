Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44791 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325Ab1CCOz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 09:55:27 -0500
Date: Thu, 3 Mar 2011 09:55:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michal Simek <monstr@monstr.eu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: NFS problem on Microblaze LE
Message-ID: <20110303145521.GB11402@fieldses.org>
References: <4D6E4052.7050201@monstr.eu>
 <20110302154900.GA29136@fieldses.org>
 <4D6E6C49.90309@monstr.eu>
 <20110302173438.GC29136@fieldses.org>
 <4D6E8A5A.8010307@monstr.eu>
 <20110302182437.GD29136@fieldses.org>
 <4D6F5F8E.7040200@monstr.eu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D6F5F8E.7040200@monstr.eu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 03, 2011 at 10:29:50AM +0100, Michal Simek wrote:
> J. Bruce Fields wrote:
> >You may also want to take a look at it yourself in wireshark.  Probably
> >you'll see the BADCRED error in one of the replies once you manage to
> >capture the right stuff.
> 
> I have looked at it and I see two things.
> 1. TCP checksum is incorrect but BE has the same behavior that's why I think it is fine.
> 2. Packet #9 (V2 UNSET Reply (Call In 8)) contains Reply state: denied and AUTH_ERROR
> bad credential (seal broken) that's the confirmation what I saw from the kernel debug logs.
> 
> What does it caused this rejection?
> 
> I am looking for it in the kernel.

The packets sent by the kernel look OK to me on a quick glance, so I'm
inclined to suspect that portmap is misparsing them somehow.  You
probably want to figure out why exactly portmap is deciding to reject
the first UNSET call.

--b.
