From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: retry= is additive with the text-based mount interface
Date: Fri, 25 Apr 2008 10:05:03 -0700
Message-ID: <1209143103.12944.1.camel@heimdal.trondhjem.org>
References: <20080425080535.GA4999@uio.no>
	 <46541DE2-4D6A-4701-A3BB-E609F0E51D6D@oracle.com>
	 <20080425163457.GA6952@uio.no>
	 <F4C3F5C0-1D60-4285-9CB3-171C70C96B03@oracle.com>
	 <20080425165921.GA7108@uio.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:53128 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761767AbYDYRFH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2008 13:05:07 -0400
In-Reply-To: <20080425165921.GA7108-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-04-25 at 18:59 +0200, Steinar H. Gunderson wrote:
> On Fri, Apr 25, 2008 at 12:45:36PM -0400, Chuck Lever wrote:
> >> fugl:~# mount -t nfs -v -o retry=0 10.0.0.11:/foo /mnt
> >> mount.nfs: timeout set for Thu Jan  1 14:40:25 1970
> >> mount.nfs: text-based options: 'retry=0,addr=10.0.0.11'
> > On my test system (Fedora 7) I get correct behavior with both /bin/mount 
> > and when using /sbin/mount.nfs directly.
> 
> It seems the patch has an issue:
> 
> +       if (!parse_retry_option(&timeout, options, NFS_DEF_FG_TIMEOUT_MINUTES))
> 
> where parse_retry_option() _adds_ to timeout. But timeout is not initialized :-)

Why would we ever want to do anything other than just set the timeout
here, Chuck?

Trond

