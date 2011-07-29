Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750840Ab1G2PHx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 11:07:53 -0400
Date: Fri, 29 Jul 2011 11:07:45 -0400
To: Fred Isaman <iisaman@netapp.com>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>, linux-nfs@vger.kernel.org
Subject: Re: pynfs and newpynfs for NFSv4 and NFSv4.1
Message-ID: <20110729150745.GH23194@fieldses.org>
References: <4E326103.6020003@cea.fr>
 <CADnza46ZRS1W96m-czgbOPPjqZ+xPr5QU05K2vgdTC5MaSGeAQ@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CADnza46ZRS1W96m-czgbOPPjqZ+xPr5QU05K2vgdTC5MaSGeAQ@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 29, 2011 at 10:33:06AM -0400, Fred Isaman wrote:
> At one point, the 4.0 and 4.1 trees were separate.  However, they have
> recently been merged, and both now (and forever more will) point to
> the same repository.

Similarly, I've still got a pynfs41.git repo but it's just a symlink to
my pynfs.git repo (which will only ever be Fred's tree plus possibly
some incoming server tests).

--b.
