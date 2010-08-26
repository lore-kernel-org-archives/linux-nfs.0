Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:36943 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab0HZP1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Aug 2010 11:27:03 -0400
Date: Thu, 26 Aug 2010 11:27:02 -0400
From: Jim Rees <rees@umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: protocol fallback when server doesn't support TCP
Message-ID: <20100826152702.GB23940@merit.edu>
References: <20100826120635.4c3157bc@notabene>
 <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <659EE931-F48E-4A5D-9212-D4F8AE421029@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:

  On Aug 25, 2010, at 10:06 PM, Neil Brown wrote:
  > Maybe the ideal would be to do a portmap probe and only fall back to v3 if
  > portmap confirm that v3 is supported and v4 isn't.

  What are the risks of checking portmap in this case?  That seems like it
  would give a better chance of a desirable outcome.

In general, portmap can't confirm that v4 isn't available, only that v3 is.
Right?
