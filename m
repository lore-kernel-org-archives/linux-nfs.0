From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] nfsd41: fix fore channel attribute initialization
Date: Mon, 14 Sep 2009 14:54:42 -0400
Message-ID: <20090914185442.GC1658@fieldses.org>
References: <1252709575-3426-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbZINSyi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 14:54:38 -0400
In-Reply-To: <1252709575-3426-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2009 at 06:52:53PM -0400, andros@netapp.com wrote:
> Fix forechannel attribute initialization
> 
> These two patches fix ca_maxresponsesize_cached, ca_maxresponsesize, and
> ca_maxrequestsize calculations for the forechannel.
> 
> Tested:

Actually the think I was interested to test was just to make sure that
the client does writes of the size it should.  (It should be able to do
1MB reads and writes, but with the previous code, I believe it would
have been a bug for the client to do so, as we weren't advertising
maxresponse/requestsizes large enough.)

--b.

> 
> Kerberos NFSv4.1 mount:
> Passes Connectathon tests. Passes the expected pynfs tests when tests are run
> individually.
> When the pynfs tests are run all at once, there are too many sessions created,
> and the server code (init_forechannel_attrs) works as planned and fails the
> CREATE SESSION with NFS4ERR_SERVERFAULT.
> 
> The pynfs 4.1 tests need to be fixed to clean up after themselves! 
> 
> -->Andy
> 
> 0001-nfsd41-fix-NFSD_MIN_HDR_SEQ_SZ.patch
> 0002-nfsd41-add-RPC-header-size-to-fore-channel-negotiat.patch
> 
