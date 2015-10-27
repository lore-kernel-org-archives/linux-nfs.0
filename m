Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33165 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932256AbbJ0QD5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Oct 2015 12:03:57 -0400
MIME-Version: 1.0
In-Reply-To: <1445628736-13058-2-git-send-email-Anna.Schumaker@Netapp.com>
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com> <1445628736-13058-2-git-send-email-Anna.Schumaker@Netapp.com>
From: Steve French <smfrench@gmail.com>
Date: Tue, 27 Oct 2015 11:03:37 -0500
Message-ID: <CAH2r5mtRzSX3dZAXZwgVLQfjjfrkX8X=7b2uxQJ+De=5JjmqCw@mail.gmail.com>
Subject: Re: [PATCH v7 1/4] vfs: add copy_file_range syscall and vfs helper
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-btrfs@vger.kernel.org,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, zab@zabbo.net,
        Al Viro <viro@zeniv.linux.org.uk>, clm@fb.com, darrick.wong@oracle.com,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com,
        Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The patch set looks good so far, and copy offload is important for
CIFS/SMB3 (not just Windows/Mac/Samba but most servers support one of
the various methods available to do this over the network via CIFS and
also SMB2/SMB3).  I have only implemented two ways of copy offload in
cifs.ko so far but will look at adding the remaining mechanisms.

Currently cifs.ko does have a similar restriction to the below one
that you have in your patch1, but I was planning to relax it (as long
as source and target are on the same server) since some of the
important use cases are having the server do copy offload from one
share to another.   So we should support the case where the files are
on the same file system type (nfs, cifs etc.) but not necessarily on
the same superblock (for the case of cifs they will be on the same
server, but with some forms of copy offload that would not necessarily
have to be on the same server).

The following check should be removed (an alternative would be to
check that source and target are the same filesystem type ie nfs, or
cifs or xfs etc. or simply let the file systems check file_in and
file_out's validity)

> +       /* this could be relaxed once a method supports cross-fs copies */
> +       if (inode_in->i_sb != inode_out->i_sb ||
> +           file_in->f_path.mnt != file_out->f_path.mnt)
> +               return -EXDEV;




-- 
Thanks,

Steve
