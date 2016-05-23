Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sender163-mail.zoho.com ([74.201.84.163]:24922 "EHLO
	sender163-mail.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752657AbcEWBU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2016 21:20:29 -0400
From: "James Johnston" <johnstonj.public@codenest.com>
To: <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
        <linux-api@vger.kernel.org>, "'Jeremy Allison'" <jra@samba.org>,
        "'Volker Lendecke'" <Volker.Lendecke@sernet.de>,
        "'Andreas Gruenbacher'" <agruenba@redhat.com>,
        "'Christoph Hellwig'" <hch@infradead.org>
Subject: Re: [PATCH v21 00/22] Richacls
Date: Mon, 23 May 2016 01:20:15 -0000
Message-ID: <036701d1b491$44b3b2a0$ce1b17e0$@codenest.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Tue, May 10, 2016 at 06:18:10AM +0200, Volker Lendecke wrote:
> > On Tue, May 10, 2016 at 12:02:33AM +0200, Andreas Gruenbacher wrote:
> > > What more can I do to finally get this merged?
> > 
> > While I am not the one to comment on kernel specifics, from a pure Samba
> > user space perspective let me say: We need this. NOW.
>
> +1 from me. This is something that many vendors need
> and have needed for a very long time. Getting this
> in will allow *large* amounts of existing storage to
> be migrated to Linux.

As a "mere" end-user of SAMBA, +1 from me also...  It's my understanding
that this patch set would help eliminate the need for hacks like
vfs_acl_xattr that store ACLs in extended attributes that only SAMBA
understands.  If the file system itself can respect the ACLs that seems
like a lot cleaner solution.

James


