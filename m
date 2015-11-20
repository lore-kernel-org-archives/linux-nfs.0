Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mondschein.lichtvoll.de ([194.150.191.11]:58810 "EHLO
	mail.lichtvoll.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbKTQfn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Nov 2015 11:35:43 -0500
From: Martin Steigerwald <martin@lichtvoll.de>
To: David Howells <dhowells@redhat.com>, linux-nfs@vger.kernel.org
Cc: arnd@arndb.de, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Date: Fri, 20 Nov 2015 17:35:37 +0100
Message-ID: <1963780.VoDvOYV05y@merkaba>
In-Reply-To: <4495.1448036915@warthog.procyon.org.uk>
References: <1502878.QisWlqATFu@merkaba> <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <4495.1448036915@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc linux-afs dropped due to bounce:

<linux-afs@vger.kernel.org>: host vger.kernel.org[209.132.180.67] said: 554
    5.0.0 Hi [194.150.191.11], unresolvable address:
    <linux-afs@vger.kernel.org>; nosuchuser; linux-afs@vger.kernel.org (in
    reply to RCPT TO command)

Am Freitag, 20. November 2015, 16:28:35 CET schrieb David Howells:
> Martin Steigerwald <martin@lichtvoll.de> wrote:
> > Any plans to add limitations of filesystem to the call like maximum file
> > size?  I know its mostly relevant for just for FAT32, but on any account
> > rather than trying to write 4 GiB and then file, it would be good to at
> > some time get a dialog at the beginning of the copy.
> 
> Adding filesystem limits can be done.  I got a shopping list of things
> people wanted a while back and I've worked off of that list.  I can add
> other things - that's on of the reasons I left room for expansion.

Cool, thank you for bringing this forward.

I am teaching in my Linux trainings since years that one day one will be able 
to see file creation time with stat shell command, actually mentioning ideas 
to make some xstat/statx system call. :)

Thanks,
-- 
Martin
