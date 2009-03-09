From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS4ERR_SYMLINK  error
Date: Mon, 09 Mar 2009 14:18:21 -0400
Message-ID: <1236622701.7234.34.camel@heimdal.trondhjem.org>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com>
	 <20090306213234.GB1779@fieldses.org> <49B2C404.3060907@panasas.com>
	 <20090309180643.GB9408@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34211 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbZCISSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Mar 2009 14:18:33 -0400
In-Reply-To: <20090309180643.GB9408@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-03-09 at 14:06 -0400, J. Bruce Fields wrote:
> > That said, I don't think a careful client implementation
> > should ever get NFS4ERR_SYMLINK if it stats the directory it operates
> > on before sending the link op (or lookup, create, rename, etc.) to make
> > sure it is indeed a directory, right?.
> 
> That sounds racy.

The LINK op identifies the target directory by its filehandle, so I
can't see that there can be any race: the server isn't supposed to be
able to morph a directory into a symlink without changing its
filehandle.

Trond

