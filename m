Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754254Ab2D0JUF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 05:20:05 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <3F302713-B675-4BAA-B2B7-235E03C5975F@dilger.ca>
References: <3F302713-B675-4BAA-B2B7-235E03C5975F@dilger.ca> <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com> <20656.1335450358@redhat.com> <24787.1335455535@redhat.com> 
To: Andreas Dilger <adilger@dilger.ca>
Cc: dhowells@redhat.com, Steve French <smfrench@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "wine-devel@winehq.org" <wine-devel@winehq.org>,
        "kfm-devel@kde.org" <kfm-devel@kde.org>,
        "nautilus-list@gnome.org" <nautilus-list@gnome.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Fri, 27 Apr 2012 10:19:09 +0100
Message-ID: <3279.1335518349@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas Dilger <adilger@dilger.ca> wrote:

> > However, since there is a remote file ID, we could add an
> > XSTAT_INFO_FILE_ID flag to indicate there's a standard xattr holding this.
> 
> It is a bit strange that the kernel would return a flag that was not
> requested, but not fatal.

On the other hand, if it costs the kernel nothing to generate this indicator...

For network filesystems, for instance, you might know that there is some other
file ID because of the way the fs is specified.

I was thinking that many of the fields will be given values, even if you don't
ask for them, because the values (or approximations thereof) are present in
memory already.

David
