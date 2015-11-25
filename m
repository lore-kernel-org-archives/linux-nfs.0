Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44096 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbbKYRvz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Nov 2015 12:51:55 -0500
Date: Wed, 25 Nov 2015 12:51:53 -0500
To: David Howells <dhowells@redhat.com>
Cc: Martin Steigerwald <martin@lichtvoll.de>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Message-ID: <20151125175153.GA30335@fieldses.org>
References: <1502878.QisWlqATFu@merkaba>
 <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <4495.1448036915@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4495.1448036915@warthog.procyon.org.uk>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2015 at 04:28:35PM +0000, David Howells wrote:
> Martin Steigerwald <martin@lichtvoll.de> wrote:
> 
> > Any plans to add limitations of filesystem to the call like maximum file
> > size?  I know its mostly relevant for just for FAT32, but on any account
> > rather than trying to write 4 GiB and then file, it would be good to at some
> > time get a dialog at the beginning of the copy.
> 
> Adding filesystem limits can be done.  I got a shopping list of things people
> wanted a while back and I've worked off of that list.  I can add other things
> - that's on of the reasons I left room for expansion.

I ran across systemd/src/basic/path-util.c:fd_is_mount_point() the other
day, and the contortions it goes through made me wonder if we should
also add mnt_id and/or an is_mountpoint boolean--it's annoying to have
to do name_to_handle_at() (not supported on all filesystems) just to get
mnt_id.

(Looking at it now I see it falls back on reading mount id from
/proc/self/fdinfo/<fd>.  Maybe that's good enough.  May depend on
whether there's a potential user that doesn't want to assume access to
/proc?)

--b.
