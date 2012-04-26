Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:45772 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077Ab2DZXZT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 19:25:19 -0400
From: Nix <nix@esperi.org.uk>
To: Roland McGrath <roland@hack.frob.com>
Cc: David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
References: <20120426182524.E5ADF2C0EC@topped-with-meat.com>
	<20120419163238.61D382C0DF@topped-with-meat.com>
	<20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<19184.1335448455@redhat.com> <9931.1335477281@redhat.com>
	<20120426220242.53FC22C0D3@topped-with-meat.com>
Date: Thu, 26 Apr 2012 23:21:08 +0100
In-Reply-To: <20120426220242.53FC22C0D3@topped-with-meat.com> (Roland
	McGrath's message of "Thu, 26 Apr 2012 15:02:42 -0700 (PDT)")
Message-ID: <87wr522kyz.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 26 Apr 2012, Roland McGrath verbalised:

>> fileinfoat() perhaps?  I think stat*at() is better, though, as people are
>> used to the stat function family.
>
> Names like that were all I had thought of when I said I hadn't thought of
> any good ones. ;-)

Quite. It's a garden-path function name. "What's a foat and why would I
want to put a file in one?"

-- 
NULL && (void)
