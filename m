From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: pnfs server data server list
Date: Fri, 4 Jun 2010 12:25:59 -0400
Message-ID: <20100604162559.GE10153@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eanderle@umich.edu
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45757 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab0FDQZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jun 2010 12:25:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We were just noticing that the pnfs/gfs2 code stores the data server
list as a comma-delimited string of ip addresses.

That string is passed from userspace without any validation--as far as I
can tell, if the adminstrator passes in random data, that random data
will get handed to the client as is.

It would be better to validate that data when it's written to the
/proc/fs/nfsd/ file--if for no other reason than to give administrators
better error messages.

While we're at it: should we just store the thing as a list of
sockaddr's instead of as a string?

I figure that would:
	- guarantee we never forget to validate the input; and
	- be more useful if we eventually use them as addresses in the
	  kernel (e.g. for MDS<->DS protocol; does anyone have a
	  prototype design for that?).

But it means some more work converting back and forth (since
getdeviceinfo still needs the addresses as strings).

--b.
