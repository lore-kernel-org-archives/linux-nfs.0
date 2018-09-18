Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34312 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727660AbeISBBL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Sep 2018 21:01:11 -0400
Date: Tue, 18 Sep 2018 15:27:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chris Siebenmann <cks@cs.toronto.edu>
Cc: Stan Hu <stanhu@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
Message-ID: <20180918192708.GE1218@fieldses.org>
References: <20180918183315.GD1218@fieldses.org>
 <20180918190606.DA690322584@apps1.cs.toronto.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180918190606.DA690322584@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 18, 2018 at 03:06:06PM -0400, Chris Siebenmann wrote:
> > The ctime changes whenever datat or attributes change.  I'm not sure
> > whether the ctime of the renamed file is expected to change.  The
> > ctime of the renamed-over file will change (if for no other reason
> > that that it's nlink value changes from 1 to 0).
> 
>  The ctime of the renamed file is usually expected (and required)
> to change (at least on local filesystems). Among other things, this
> is how backup programs traditionally detect renamed files during
> incremental backups.
> 
>  Some Linux filesystems have had problems here in the past (changing
> ctime on rename is an obscure corner case), but I think all mainstream
> ones work right these days.

Got it, thanks!--b.
