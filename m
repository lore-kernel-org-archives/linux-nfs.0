From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 6/7] nfsd: restrict filehandles accepted in V4ROOT case
Date: Fri, 4 Dec 2009 13:49:59 -0500
Message-ID: <20091204184959.GA19236@fieldses.org>
References: <1259714383-32577-1-git-send-email-bfields@citi.umich.edu> <1259714383-32577-2-git-send-email-bfields@citi.umich.edu> <1259714383-32577-3-git-send-email-bfields@citi.umich.edu> <1259714383-32577-4-git-send-email-bfields@citi.umich.edu> <1259714383-32577-5-git-send-email-bfields@citi.umich.edu> <1259714383-32577-6-git-send-email-bfields@citi.umich.edu> <1259714383-32577-7-git-send-email-bfields@citi.umich.edu> <4B192525.4050301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53915 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbZLDSsv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 13:48:51 -0500
In-Reply-To: <4B192525.4050301-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 04, 2009 at 10:05:09AM -0500, Steve Dickson wrote:
> 
> 
> On 12/01/2009 07:39 PM, J. Bruce Fields wrote:
> > +	/*
> > +	 * A pseudoroot export gives permission to access only one
> > +	 * single directory; the kernel has to make another upcall
> > +	 * before granting access to anything else under it:
> > +	 */
> > +	if (unlikely(dentry->d_parent != exp->ex_path.dentry))
> Remember this is wrong... it needs to be 
> -	if (unlikely(dentry->d_parent != exp->ex_path.dentry))
> +	if (unlikely(dentry != exp->ex_path.dentry))

Oops, thanks.  Looking back through the git reflogs....  It seems that I
had this fix in a separate patch, was rebasing the series and squashing
that patch in at the same time, and missed this chunk.  Fixed in my
local version.

--b.
