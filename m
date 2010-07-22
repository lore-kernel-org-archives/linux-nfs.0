Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:51809 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab0GVKwh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 06:52:37 -0400
Date: Thu, 22 Jul 2010 12:52:36 +0200 (CEST)
From: Jan Engelhardt <jengelh@medozas.de>
To: Christoph Hellwig <hch@infradead.org>
cc: David Howells <dhowells@redhat.com>, viro@ZenIV.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-kernel@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        drepper@redhat.com, torvalds@linux-foundation.org
Subject: Re: [PATCH 02/18] xstat: Add a pair of system calls to make extended
 file stats available [ver #6]
In-Reply-To: <20100718084824.GA27794@infradead.org>
Message-ID: <alpine.LSU.2.01.1007221248050.9353@obet.zrqbmnf.qr>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk> <20100715021712.5544.44845.stgit@warthog.procyon.org.uk> <20100718084824.GA27794@infradead.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sunday 2010-07-18 10:48, Christoph Hellwig wrote:

>Adding Uli to the Cc list to make sure this system call is useful
>for glibc / can be exported by it.  Otherwise it's rather pointless
>to add it.
>
>>  (6) BSD stat compatibility: Including more fields from the BSD stat such as
>>      creation time (st_btime) and inode generation number (st_gen) [Jeremy
>>      Allison, Bernd Schubert]
>
>How is this different from (1) and (4)?

(4), the inode generation number, need not be related to time.

>>  (8) Allow the filesystem to indicate what it can/cannot provide: A filesystem
>>      can now say it doesn't support a standard stat feature if that isn't
>>      available.
>
>What for?

Given xstat.otime=0, how would you determine whether the file is really 
tagged with a date of 1970, or whether it's just the fs which didnot 
store this kind of information.
