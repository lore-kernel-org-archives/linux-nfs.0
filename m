Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58513 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810Ab2CPUfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 16:35:22 -0400
Date: Fri, 16 Mar 2012 16:35:21 -0400
To: Alexandre Depoutovitch <adepoutovitch@vmware.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: About Direct I/O
Message-ID: <20120316203521.GA22929@fieldses.org>
References: <CAAJC9VbxAcE+DqjqaZ-9K4HKpAWKgg0_B9_QFk64b5V-QdotQA@mail.gmail.com>
 <6866525b.00001bd8.0000023d@aldep-VC.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6866525b.00001bd8.0000023d@aldep-VC.vmware.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 16, 2012 at 11:14:04AM -0700, Alexandre Depoutovitch wrote:
> Hello,
> I am trying to do random sector aligned writes to an NFS mounted disk. The
> performance is order of magnitude worse than 4K (file system block size)
> aligned I/O.
> The reason is that NFS demon (Linux kernel 2.6.32) on the server side
> always does buffered I/O, which behaves poorly for block unaligned
> requests.
> Is there a way to tell NFS daemon to use direct I/O? 

No.

> If not, is it an implementation limitation or there is a fundamental
> problem with using direct I/O in NFS server?

I'm shamefully ignorant of Direct IO....

If we supported Direct IO, are there heuristics that would let the
server figure out on its own when it helped and when it didn't?  Or
would the administrator be stuck trying to figure that out?

Is Direct IO possible from kernel buffers these days?  Are there
alignment restrictions?

--b.
