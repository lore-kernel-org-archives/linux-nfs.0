Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbbKTQ2n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 11:28:43 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1502878.QisWlqATFu@merkaba>
References: <1502878.QisWlqATFu@merkaba> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
To: Martin Steigerwald <martin@lichtvoll.de>
Cc: dhowells@redhat.com, arnd@arndb.de, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 20 Nov 2015 16:28:35 +0000
Message-ID: <4495.1448036915@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Steigerwald <martin@lichtvoll.de> wrote:

> Any plans to add limitations of filesystem to the call like maximum file
> size?  I know its mostly relevant for just for FAT32, but on any account
> rather than trying to write 4 GiB and then file, it would be good to at some
> time get a dialog at the beginning of the copy.

Adding filesystem limits can be done.  I got a shopping list of things people
wanted a while back and I've worked off of that list.  I can add other things
- that's on of the reasons I left room for expansion.

David
