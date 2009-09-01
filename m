From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not
 specified by user
Date: Tue, 01 Sep 2009 14:35:34 -0400
Message-ID: <1251830134.18608.38.camel@heimdal.trondhjem.org>
References: <20090901143012.3978.11441.stgit@matisse.1015granger.net>
	 <20090901150545.GA22846@fieldses.org>
	 <7C5C14D9-F315-4DF8-A2F4-C7F0981AC968@oracle.com>
	 <20090901151830.GC22846@fieldses.org>
	 <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com>
	 <20090901160914.GG22846@fieldses.org>
	 <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com>
	 <20090901163846.GJ22846@fieldses.org>
	 <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com>
	 <1251829540.18608.31.camel@heimdal.trondhjem.org>
	 <1251829737.18608.34.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59868 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbZIASfl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 14:35:41 -0400
In-Reply-To: <1251829737.18608.34.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-09-01 at 14:28 -0400, Trond Myklebust wrote:
> We should also try it if the server is broken, and returns an empty
> list, but only after first attempting to cycle through all the other
> flavours that are supported by the client.

Note that this is also what we'll have to do in the case of NFSv4 minor
version 0, when trying to get round the problem of applying SECINFO to
the root directory.

NFSv4.1 doesn't have that problem, since you are always allowed to do
"PUTROOTFH; SECINFO_NO_NAME"...

Trond

