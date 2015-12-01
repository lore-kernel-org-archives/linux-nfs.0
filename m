Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56623 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754713AbbLARJ2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Dec 2015 12:09:28 -0500
Date: Tue, 1 Dec 2015 12:09:20 -0500
From: Chris Mason <clm@fb.com>
To: Christoph Hellwig <hch@lst.de>
CC: <viro@zeniv.linux.org.uk>, <tao.peng@primarydata.com>,
        <jeff.layton@primarydata.com>, <linux-fsdevel@vger.kernel.org>,
        <linux-btrfs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-cifs@vger.kernel.org>
Subject: Re: vfs: move btrfs clone ioctls to common code
Message-ID: <20151201170920.GB8918@ret.masoncoding.com>
References: <1448563859-21922-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
In-Reply-To: <1448563859-21922-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 26, 2015 at 07:50:54PM +0100, Christoph Hellwig wrote:
> This patch set moves the existing btrfs clone ioctls that other file
> system have started to implement to common code, and allows the NFS
> server to export this functionality to remote systems.
> 
> This work is based originally on my NFS CLONE prototype, which reused
> code from Anna Schumaker's NFS COPY prototype, as well as various
> updates from Peng Tao to this code.
> 
> The patches are also available as a git branch and on gitweb:
> 
> 	git://git.infradead.org/users/hch/pnfs.git clone-for-viro

Thanks Christoph, this looks fine to me.

-chris

