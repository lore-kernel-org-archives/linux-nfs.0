Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p3plsmtpa08-02.prod.phx3.secureserver.net ([173.201.193.103]:43450
	"EHLO p3plsmtpa08-02.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751462Ab3FLCmU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Jun 2013 22:42:20 -0400
Message-ID: <51B7DE9C.6080703@talpey.com>
Date: Tue, 11 Jun 2013 22:36:12 -0400
From: Tom Talpey <tom@talpey.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Sandeep Joshi <sanjos100@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: why does nfsd write not use splice
References: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com> <20130611195140.GA29634@fieldses.org>
In-Reply-To: <20130611195140.GA29634@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/11/2013 3:51 PM, J. Bruce Fields wrote:
> On Sun, Jun 09, 2013 at 01:05:16PM +0530, Sandeep Joshi wrote:
>> Is there a reason as to why the nfsd server does not use splice in the
>> write calls - nfsd_vfs_write() ?  Is there some structural limitation
>> or is it just something nobody got around to implementing ?
>>
>> I have looked at the source back to the 2.6.x kernels and it seems
>> only nfsd_vfs_read() has ever used splice/sendfile.
>> http://lxr.linux.no/linux+v3.9.5/fs/nfsd/vfs.c
>
> I don't actually know how splice_write works.... I assume to avoid a
> copy we'd have to place the incoming write data into pages already
> correctly aligned.  That would be an interesting trick.

NFS-RDMA does that, by design. ;-)
