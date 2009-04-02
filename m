From: Miles Bader <miles-mXXj517/zsQ@public.gmane.org>
Subject: Re: [GIT PULL] Please pull the first batch of NFS client changes (and cachefs merge)...
Date: Thu, 02 Apr 2009 13:33:40 +0900
Message-ID: <buoprfv8yjf.fsf@dhlpc061.dev.necel.com>
References: <alpine.LFD.2.00.0904010935000.4130@localhost.localdomain>
	<1238522824.6577.5.camel@heimdal.trondhjem.org>
	<19756.1238606665@redhat.com>
Reply-To: Miles Bader <miles-mXXj517/zsQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds
	<public-torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	Trond Myklebust
	<public-Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>,
	public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org,
	Linux Kernel Mailing List
	<public-linux-kernel-u79uwXL29TY76Z2rM5mHXA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
To: David Howells
	<public-dhowells-H+wXaHxf7aLQT0dZR+AlfA-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blaine.gmane.org ([80.91.229.8]:56204 "EHLO hugh.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369AbZDBEl1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Apr 2009 00:41:27 -0400
Received: from public by hugh.gmane.org with local (Exim 4.63)
	(envelope-from <public-z5DuStaUktnZ+VzJOa5vwg@public.gmane.org>)
	id 1LpEjv-0001XB-1I
	for linux-nfs@vger.kernel.org; Thu, 02 Apr 2009 06:41:19 +0200
In-Reply-To: <19756.1238606665@redhat.com> (David Howells's message of "Wed,
	01 Apr 2009 18:24:25 +0100")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA-XMD5yJDbdMReXY1tMh2IBg@public.gmane.org> writes:
>> What the hell is that "cf-" and "fsc-" prefix?
>
> One editor with many files open all of the same base name (namei.c, proc.c,
> security.c, xattr.c, page.c for example).

If it's emacs, try enabling `uniquify', e.g.:

   M-x load-library RET uniquify RET
   M-x customize-variable RET uniquify-buffer-name-style RET

It will name your buffers nicely incorporating enough of the leading
path to make them unique.

[I like the `post-forward' style myself...]

-Miles

-- 
Inhumanity, n. One of the signal and characteristic qualities of humanity.


