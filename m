From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Reference to file size in nfsd_create_v3
Date: Tue, 25 Aug 2009 12:18:45 -0400
Message-ID: <20090825161845.GD26206@fieldses.org>
References: <4A449074.6060600@gluster.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46877 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754823AbZHYQSn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 12:18:43 -0400
In-Reply-To: <4A449074.6060600-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 26, 2009 at 02:40:12PM +0530, Shehjar Tikoo wrote:
> Hi All
>
> I am looking at the fs/nfsd/vfs.c:nfsd_create_v3 function.
> In there, a comment says:
> "furthermore, if the size is nonzero, we should ignore it
> according to spec!"
>
> Could someone please point out the section in RFC1813 where this
>  particular point is specified?

It's referring to the third paragraph of the DESCRIPTION section of the
OPEN operation (14.2.16) in rfc 3530.

--b.
