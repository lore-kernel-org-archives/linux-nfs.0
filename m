Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35227 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbcCUP4X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 11:56:23 -0400
Received: by mail-ob0-f181.google.com with SMTP id fp4so178314743obb.2
        for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 08:56:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160321144349.GA12804@lst.de>
References: <CAPSG9dbOPRv_gM_w_Ys9fJ-fSPRnw+Rgb3yaaHVEqZ9YyDntzg@mail.gmail.com>
 <20160321144349.GA12804@lst.de>
From: Nelson Elhage <nelhage@nelhage.com>
Date: Mon, 21 Mar 2016 08:56:03 -0700
Message-ID: <CAPSG9dZX45Uq07Xue55Aom3i-WyH9_SA_SKydBjsEX1Y14VwoA@mail.gmail.com>
Subject: Re: NFSv3 may inappropriately return EPERM for fsetxattr
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org, Bruce Fields <bfields@fieldses.org>,
        James Brown <jbrown@easypost.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's correct. The other detail that seems to be important is that
the user making the call must be different from the user owning the
file. We've also been using user remapping on the server, so that
non-xattr calls succeed in that configuration.

The reproducer James added in the bugzilla is:

(on machine with IP address 10.1.1.1)
sudo mkdir /nfs_test
sudo useradd -u 10000 test_user
sudo chown test_user /nfs_test
echo "/nfs_test 10.1.1.2(rw,all_squash,anonuid=10000)" | sudo tee -a
/etc/exports
sudo exportfs -a

(on machine with IP address 10.1.1.2)
sudo mkdir /nfs_test
sudo mount -t nfs -o vers=3,noacl 10.1.1.1:/nfs_test /nfs_test
touch /nfs_test/foo
install -m 755 /nfs_test/foo /nfs_test/bar

- Nelson

On Mon, Mar 21, 2016 at 7:43 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Hi Nelson,
>
> this was indeed most likely caused by my patch.  Just to narrow things
> down can your clarify that the scenarious is that you have CONFIG_NFS_V3
> set on your client, you're talking to a server not supporting ACLs
> at all, and a tool trying to set an ACL is getting the wrong return
> value?  If so I should be able to reproduce this locally.
