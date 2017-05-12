Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:33479 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750991AbdELNz4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 May 2017 09:55:56 -0400
Subject: Re: [RFC][PATCH 00/14] VFS: Introduce superblock configuration
 context [ver #2]
To: David Howells <dhowells@redhat.com>
CC: <mszeredi@redhat.com>, <viro@zeniv.linux.org.uk>,
        <jlayton@redhat.com>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <68231d1a-9902-ce3d-73e3-6e74754832e4@Netapp.com>
 <149451118535.4599.16084557087363834548.stgit@warthog.procyon.org.uk>
 <9616.1494530672@warthog.procyon.org.uk>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <5610bd4e-b0a4-79d5-a90e-54cb9e63299f@Netapp.com>
Date: Fri, 12 May 2017 09:55:24 -0400
MIME-Version: 1.0
In-Reply-To: <9616.1494530672@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/11/2017 03:24 PM, David Howells wrote:
> Anna Schumaker <Anna.Schumaker@Netapp.com> wrote:
> 
>> Is there any way to split the NFS patch into multiple pieces?
> 
> Are you okay with a patch or two that add code that is unconnected in that
> patch, but connected in a later one?

Yes, I'm okay with that.  Thanks for working on this!

Anna

> 
> David
> 
