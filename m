From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Is order for "exportfs -r" and rpc.mountd important?
Date: Thu, 4 Dec 2008 09:35:53 -0500
Message-ID: <20081204143553.GC3495@fieldses.org>
References: <200811281541.39272.t.bubeck@reinform.de> <200812041025.02563.t.bubeck@reinform.de> <4937E243.1080608@RedHat.com> <200812041516.14114.t.bubeck@reinform.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: "Dr. Tilmann Bubeck" <t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753882AbYLDOf4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 09:35:56 -0500
In-Reply-To: <200812041516.14114.t.bubeck-dx1aEnP5Zukb1SvskN2V4Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 04, 2008 at 03:16:13PM +0100, Dr. Tilmann Bubeck wrote:
> It's very good that it is fixed in Fedora (my preferred distribution), but it 
> is still wrong in SuSe (verified) and probably more.
> 
> A better way would be to fix NFS and its utilities itself instead of fixing 
> the distribution. This means, that the way the kernel and nfs-utils interact 
> should be made more robust (see my posting before).

The problem of exportfs ignoring the uuid, at least, should be easy
enough to fix.

I'd start by looking for the relevant code in nfs-utils/utils/exportfs/
that passes the export entry down to the kernel and figure out what
mountd is doing that it's not.

--b.
