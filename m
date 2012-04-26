Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700Ab2DZOE7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 10:04:59 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4F9088D6.9020203@cs.ucla.edu>
References: <4F9088D6.9020203@cs.ucla.edu> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <20120419163238.61D382C0DF@topped-with-meat.com>
To: Paul Eggert <eggert@cs.ucla.edu>
Cc: dhowells@redhat.com, Roland McGrath <roland@hack.frob.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-ext4@vger.kernel.org, wine-devel@winehq.org, kfm-devel@kde.org,
        nautilus-list@gnome.org, linux-api@vger.kernel.org,
        libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 15:04:07 +0100
Message-ID: <19638.1335449047@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul Eggert <eggert@cs.ucla.edu> wrote:

> On 04/19/2012 09:32 AM, Roland McGrath wrote:
> > I have no comment on the functionality.  But "xstat" is probably a poor
> > choice of name. 
> 
> In AIX 7.1 the (similar) function is called statxat instead of xstat.
> The API isn't exactly the same, but it's the same basic idea.
> Might be worth looking at, not merely to see whether the API
> should be the same, but also to borrow good ideas even if not.
> 
> http://pic.dhe.ibm.com/infocenter/aix/v7r1/topic/com.ibm.aix.basetechref/doc/basetrf2/statx.htm

Interesting.  I wasn't intending to provide both statx() and statxat()
variants, just the latter, in which case I'd've though that -at suffix is
redundant.

I note that they split their time fields into separate seconds and ns fields,
presumably for better packing.

David
