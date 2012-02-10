Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759724Ab2BJSvo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 13:51:44 -0500
Date: Fri, 10 Feb 2012 13:51:41 -0500
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: steve <steve@steve-ss.com>, whats_up@gmx.net, linux-nfs@vger.kernel.org
Subject: Re: mount hangs in NFS4+Kerberos setup
Message-ID: <20120210185141.GB5781@fieldses.org>
References: <20120210154526.7b504146@little-poseidon>
 <4F35512A.9050500@steve-ss.com>
 <20120210184154.03fb6907@little-poseidon>
 <4F355CD2.6040603@steve-ss.com>
 <4F35603A.5050508@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F35603A.5050508@fifthhorseman.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 10, 2012 at 01:21:46PM -0500, Daniel Kahn Gillmor wrote:
> On 02/10/2012 01:07 PM, steve wrote:
> > Officially, you should not export from a pseudo root. Please see the
> > last few lines in the link I sent.
> 
> That link offers the same assertion but no explanation for it.  Can you
> explain why that's the recommendation?
> 
> If an admin were to remove fsid=0 from their exports line, they'd also
> need to adjust the paths in all the connecting clients, right?

Yep.

The main problem with the fsid=0 trick is that your v3 and v4 clients
end up with different paths.

--b.
