From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Fri, 25 Apr 2008 10:01:28 +0200
Message-ID: <20080425080128.GA4848@uio.no>
References: <20080423214929.GA24387@uio.no> <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:59756 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758897AbYDYIBd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2008 04:01:33 -0400
In-Reply-To: <2CE28767-23B0-4F6C-AE53-4921D73B2782@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2008 at 10:12:58AM -0400, Chuck Lever wrote:
> Start with "mount.nfs -v" to see if the mount command tells you anything 
> interesting.  Then do a raw network trace to see what's failing during 
> the mount version/protocol negotiation.

There's nothing in -v except that it adds an addr= field. As for the
packet dump, that's the most interesting part -- for my part, the server
doesn't have iptables, so I'm blocking on the client. In that case, exactly
zero packets enter the write before mount gives up...

The other submitters have iptables blocking on the server, though, and it
doesn't work for them either (one is using NFSv3, the other NFSv4). Is this
really working for you?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
