Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56066 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352Ab3LETpn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Dec 2013 14:45:43 -0500
Date: Thu, 5 Dec 2013 14:45:37 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131205194537.GA32681@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <20131204083118.GA30216@infradead.org>
 <529F0EDD.1070403@pingtimeout.net>
 <20131204111933.GA20218@infradead.org>
 <529F1347.5000705@pingtimeout.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <529F1347.5000705@pingtimeout.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:34:31PM +0200, Antti Tönkyrä wrote:
> On 2013-12-04 13:19, Christoph Hellwig wrote:
> >On Wed, Dec 04, 2013 at 01:15:41PM +0200, Antti T?nkyr? wrote:
> >>>On 2013-12-04 10:31, Christoph Hellwig wrote:
> >>>> >Please just fix ntfs to do the mapping for you, EILSEQ is not an
> >>>> >error the VFS or applications expect either.
> >>>> >
> >>>How would you propose the mapping to be done? Are you sure about
> >>>EILSEQ not being an error that VFS/applications expect, my userspace
> >>>tools seem to handle local filesystem returning EILSEQ just fine?
> >EILSEQ doesn't have a specified meaning for VFS operations.  Of course
> >your app could handle it in some way, but that's your implementation
> >specific way that has not base for it.
> >
> Okay, I understand your point. However, in this case I was referring
> to basic GNU/Linux userspace tools which I can hardly call my own
> apps :)
> 
> All in all I guess we could keep the current mapping path which
> eventually leads into I/O error. Next we should understand why the
> share fails when I/O error is emitted...

OK, that fixed....

I'm still confused about the question of what error to return.

I don't think man pages or posix allow open to fail because of a bad
name, but there are filesystems that do, so you're stuck returning
something.

>From a grep of EILSEQ in fs/ it looks like that's what ntfs and befs
return on lookups of bad utf-8.

I guess NFS will return EINVAL (if the server follows 3530).

--b.
