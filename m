Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from such.a.cut3.name ([176.9.57.153]:59260 "EHLO such.a.cut3.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752063AbcIAU63 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 16:58:29 -0400
Subject: Re: Un-unmountable NFS mountpoints with "Stale NFS file handle" - is
 this normal behavior?
To: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org
References: <b0e2b37b-5d90-ea9c-46e9-be577c4da634@hohmatik.de>
 <87a8fsca7l.fsf@notabene.neil.brown.name>
From: Karsten Hohmeier <karsten@hohmatik.de>
Message-ID: <4777cda9-014d-0e58-048e-cfa903fff2da@hohmatik.de>
Date: Thu, 1 Sep 2016 21:07:01 +0200
MIME-Version: 1.0
In-Reply-To: <87a8fsca7l.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=iso-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the helpful answer!

> This was fixed 3 years ago in Linux 3.12

I guess it is time to update that machine then ...

> 
> Commit: 8033426e6bdb ("vfs: allow umount to handle mountpoints without revalidating them")
> 
> (and probably a few other related patches).
> 
> You need to be sure you have a version of util-linux where "umount -f"
> and "umount -l" don't stat() the mount point.
> 
> NeilBrown

In dev. time terms digging this up is pretty much archeology.

Best regards

Karsten Hohmeier

