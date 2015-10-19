Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50382 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119AbbJSUpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Oct 2015 16:45:05 -0400
Date: Mon, 19 Oct 2015 16:45:03 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com
Subject: Re: [PATCH v6 5/4] copy_file_range.2: New page documenting
 copy_file_range()
Message-ID: <20151019204503.GA15214@fieldses.org>
References: <1445029707-31549-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445029707-31549-6-git-send-email-Anna.Schumaker@Netapp.com>
 <20151018183013.GA11200@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151018183013.GA11200@infradead.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 18, 2015 at 11:30:13AM -0700, Christoph Hellwig wrote:
> Just commenting on the man page here as the comment is about sematics.
> All the infrastructure in the patch looks reasonable to me, but this
> is something we need to get right.
> 
> > +.B COPY_FR_REFLINK
> > +Create a lightweight "reflink", where data is not copied until
> > +one of the files is modified.
> > +.PP
> > +The default behavior
> > +.RI ( flags
> > +== 0) is to perform a full data copy of the requested range.
> > +.SH RETURN VALUE
> > +Upon successful completion,
> > +.BR copy_file_range ()
> > +will return the number of bytes copied between files.
> > +This could be less than the length originally requested.
> 
> As mentioned in the previous discussion I fundamentally disagree with
> the way your word the flags here.
> 
> flags = 0 gives you the data from source at dest, period.  How it's
> implemented is up to the file system as a user cannot observe how data
> actually is stored underneath.
> 
> Additionaly I think the 'clone' option with it's stronger guarantees
> should be a separate system call.  So for now just have no supported
> flag and leave it up to the file system and storage device how to
> implement it.

So, continue to include a "flags" field but just error out if it's
anything but zero for now?

Sounds fine by me.  We can always implement the other stuff later.

--b.

> 
> For the future a COPY_FALLOC flag taht guaranatees you do not get ENOSPC
> on the copied range will be very useful, but given the complexity I
> think it's not something we should add now.
