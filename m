Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:35566 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751676Ab2BTCBx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2012 21:01:53 -0500
Date: Sun, 19 Feb 2012 21:01:48 -0500
From: Jim Rees <rees@umich.edu>
To: Chris Rankin <rankincj@yahoo.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [OOPS] NFS dereferenced NULL pointer with 3.2.6 kernel.
Message-ID: <20120220020148.GB20376@umich.edu>
References: <4F4194C4.40104@yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F4194C4.40104@yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chris Rankin wrote:

  My 3.2.6 (x86, 32 bit) kernel oopsed last night while pulling a file
  across an NFS mount:

I think this is fixed by commit 331818f1c4, "Fix an Oops in the NFSv4 getacl
code."  Shouldn't this be in stable by now?  It doesn't seem to be.
