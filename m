From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP
	snd/rcv buffer values
Date: Fri, 13 Jun 2008 16:53:39 -0400
Message-ID: <20080613205339.GM8501@fieldses.org>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57975 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717AbYFMUxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 16:53:42 -0400
In-Reply-To: <48518F18.2010703@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 12, 2008 at 02:03:20PM -0700, Dean Hildebrand wrote:
> Another point is that setting the buffer size isn't always a  
> straightforward process.  All papers I've read on the subject, and my  
> experience confirms this, is that setting tcp buffer sizes is more of an  
> art.

Aie.  It's bad enough if we have a half-dozen or so sysctl's to set to
get decent performance out of the nfs server.  I don't like to hear
that, on top of that, the choice of at least one of those variables is
an art....

We can leave some knobs in there for the people that like to read that
sort of paper, but the rest of the world will need *some* sort of
heuristics.

--b.
