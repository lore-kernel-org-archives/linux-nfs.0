Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f171.google.com ([209.85.212.171]:56992 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063AbaHKU05 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Aug 2014 16:26:57 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so4853735wib.4
        for <linux-nfs@vger.kernel.org>; Mon, 11 Aug 2014 13:26:56 -0700 (PDT)
Date: Mon, 11 Aug 2014 21:28:19 +0100
From: Ross Lagerwall <rosslagerwall@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd3: Check write permission after checking existence
Message-ID: <20140811202819.GA11589@hobo.lan>
References: <1407591840-19080-1-git-send-email-rosslagerwall@gmail.com>
 <20140811190838.GE9095@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140811190838.GE9095@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2014 at 03:08:38PM -0400, J. Bruce Fields wrote:
> On Sat, Aug 09, 2014 at 02:44:00PM +0100, Ross Lagerwall wrote:
> > When creating a file that already exists in a read-only directory with
> > O_EXCL, the NFSv3 server returns EACCES rather than EEXIST (which local
> > files and the NFSv4 server return).  Fix this by checking the MAY_CREATE
> > permission only if the file does not exist.  Since this already happens
> > in do_nfsd_create, the check in nfsd3_proc_create can simply be removed.
> 
> Thanks.
> 
> From a look at the history I believe the server has behaved this way
> since the beginning.  Is this creating a practical problem for you?  How
> did you notice it?

I help maintain GNOME's gvfs and so I have a bunch of test programs
which I run to check for conformance.  I noticed that:
gvfs-save /mnt/dir/file
fails with a permission denied error when file is on an NFSv3 mount and
dir is read-only.  Basically, gvfs-save first tries to create the file.
If it already exists, then it just truncates it.  But on NFSv3, the
first creation generates a permission denied error so the operation is
aborted.

Not really a practical problem, but it is possible to see this with
various real-world programs which do a similar dance when saving like
this:
open(path, O_WRONLY|O_CREAT|O_EXCL)
if EEXIST:
  open(path, O_WRONLY|O_CREAT|O_TRUNC)
else:
  bail()

(For Linux NFS clients, the kernel does its own client-side caching so
if you do:
ls /mnt/dir; gvfs-save /mnt/dir/file
it magically works!)

> 
> Inclined to apply it just for consistency as you suggest.  And because
> it removes some unnecessary code.  But as a low priority: for 3.18 and
> not stable.
> 

OK, your decision.  That is OK with me.

Cheers,
-- 
Ross Lagerwall
