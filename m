Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45941 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbbKXINL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 03:13:11 -0500
Date: Tue, 24 Nov 2015 00:13:08 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Martin Steigerwald <martin@lichtvoll.de>
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Message-ID: <20151124081308.GB8840@infradead.org>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
 <1502878.QisWlqATFu@merkaba>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1502878.QisWlqATFu@merkaba>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 20, 2015 at 05:19:31PM +0100, Martin Steigerwald wrote:
> I know its mostly relevant for just for FAT32, but on any account rather than 
> trying to write 4 GiB and then file, it would be good to at some time get a 
> dialog at the beginning of the copy.

pathconf/fpathconf is supposed to handle that.  It's not super pretty
but part of Posix.  Linus hates it, but it might be time to give it
another try.
