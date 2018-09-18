Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:59754 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728657AbeISAkF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2018 20:40:05 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Stan Hu <stanhu@gmail.com>, linux-nfs@vger.kernel.org,
        cks@cs.toronto.edu
Subject: Re: Stale data after file is renamed while another process has an open file handle
In-reply-to: bfields's message of Tue, 18 Sep 2018 14:33:15 -0400.
             <20180918183315.GD1218@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 18 Sep 2018 15:06:06 -0400
Message-Id: <20180918190606.DA690322584@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> The ctime changes whenever datat or attributes change.  I'm not sure
> whether the ctime of the renamed file is expected to change.  The
> ctime of the renamed-over file will change (if for no other reason
> that that it's nlink value changes from 1 to 0).

 The ctime of the renamed file is usually expected (and required)
to change (at least on local filesystems). Among other things, this
is how backup programs traditionally detect renamed files during
incremental backups.

 Some Linux filesystems have had problems here in the past (changing
ctime on rename is an obscure corner case), but I think all mainstream
ones work right these days.

	- cks
