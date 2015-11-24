Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mondschein.lichtvoll.de ([194.150.191.11]:39715 "EHLO
	mail.lichtvoll.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965AbbKXIs0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 03:48:26 -0500
From: Martin Steigerwald <martin@lichtvoll.de>
To: Christoph Hellwig <hch@infradead.org>, linux-btrfs@vger.kernel.org
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Date: Tue, 24 Nov 2015 09:48:22 +0100
Message-ID: <51731897.vGpjiNuy9t@merkaba>
In-Reply-To: <20151124081308.GB8840@infradead.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <1502878.QisWlqATFu@merkaba> <20151124081308.GB8840@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Dienstag, 24. November 2015, 00:13:08 CET schrieb Christoph Hellwig:
> On Fri, Nov 20, 2015 at 05:19:31PM +0100, Martin Steigerwald wrote:
> > I know its mostly relevant for just for FAT32, but on any account rather
> > than trying to write 4 GiB and then file, it would be good to at some
> > time get a dialog at the beginning of the copy.
> 
> pathconf/fpathconf is supposed to handle that.  It's not super pretty
> but part of Posix.  Linus hates it, but it might be time to give it
> another try.

It might be interesting for BTRFS as well, to be able to ask what amount of 
free space there currently is *at* a given path. Cause with BTRFS and 
Subvolumes this may differ between different paths. Even tough its not 
implemented yet, it may be possible in the future to have one subvolume with 
RAID 1 profile and one with RAID 0 profile.

That said an application wanting to make sure it can write a certain amount of 
data can use fallocate. And thats thats the only reliable way to ensure it, I 
know of. Which can become tedious for several files, but there is no principal 
problem with preallocating all files if their sizes are known. Even rsync or 
desktop environments could work like that. First fallocate everything, then, 
only if that succeeds, start actually copying data. Disadvantage: On aborted 
copies you have all files with their correct sizes and no easy indicates on 
where the copy stopped.

Thanks,
-- 
Martin
