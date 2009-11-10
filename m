From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exportfs: Warning: /adir does not support NFS export.
Date: Tue, 10 Nov 2009 13:07:47 -0500
Message-ID: <20091110180747.GA15000@fieldses.org>
References: <4AF99861.7030103@aimvalley.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Norbert van Bolhuis <nvbolhuis-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50716 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756071AbZKJSHc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Nov 2009 13:07:32 -0500
In-Reply-To: <4AF99861.7030103-bYiImlzuGf1HoQZOM9yvow@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 10, 2009 at 05:44:17PM +0100, Norbert van Bolhuis wrote:
>
> I get the following exportfs 1.2.0 warning:
>
> exportfs: Warning: /adir does not support NFS export.
>
> Although everything works fine, I'm worried about this.
>
> The directoy "/adir" is the path to a ISOZFS loop mounted image.

What's ISOZFS?

> The ISO(Z)FS image itself resides on a UBIFS filesystem (/flashfs/isozfs_image.iso).
> The root dir ("/"), as well as "/adir" and "/flashfs" is initramfs.
>
> So afaik I'm exporting a ISOFS, this is supported by nfsd (in the kernel), so
> why is the warning there ?
>
> I know UBIFS doesn't support to be (nfsd) exported by the kernel,
> but ISO(Z)FS and initramfs do, right ?
>
> Am I doing something illegal ?

Which distribution are you using?  Is it something that worked before,
and stopped working, or is this the first time you've tried it?

--b.
