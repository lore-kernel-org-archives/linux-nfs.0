From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux pNFS status meeting  5/06/10
Date: Wed, 5 May 2010 16:05:25 -0400
Message-ID: <20100505200524.GF14703@fieldses.org>
References: <4BE1A15E.5030907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs mailing list <pnfs@linux-nfs.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36448 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755693Ab0EEUF0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 May 2010 16:05:26 -0400
In-Reply-To: <4BE1A15E.5030907@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 05, 2010 at 09:48:30AM -0700, Dean Hildebrand wrote:
> Meeting on Thursday 5/06/2010 at 9:30 AM PDT (12:30 PM EST).

Rough agenda:

1. upstream status/merge plans (trond, bfields)

2. State of pNFS tree (bhalevy)

3. Mailing list change

4. Client
	4.1. Client pNFS status
	4.2. Client state management design documentation (trond)

5. Server
	5.1. Todo's for minimal 4.1 server (bfields)
		http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues
		- pynfs testing
			- ERR_DELAY handling (iisaman)
			- deferral fixes (bfields)
	5.2. pnfs
		- Jiri Kortus's testing?

6. documentation
	- wiki organization, collect pnfs setup howto's (steved)

7. redhat status (steved)
	- update to latest tag
	- steved will help boaz get started on rpm-building, for exofs.

8. bakeathon plans
	- Summer in Ann Arbor
	- Fall in Boston

9. new business

10. next meeting

--b.
