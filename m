Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail09.linbit.com ([212.69.161.110]:59949 "EHLO
	mail09.linbit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660Ab1JUKwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 06:52:12 -0400
Subject: Re: [PATCH -V7 21/26] richacl: xattr mapping functions
From: Andreas Gruenbacher <agruen@kernel.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Fri, 21 Oct 2011 12:52:10 +0200
In-Reply-To: <874nz265tq.fsf@linux.vnet.ibm.com>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1318951981-5508-22-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <20111019222021.GB1874@fieldses.org> <87k4805alx.fsf@linux.vnet.ibm.com>
	 <20111020091434.GC5444@fieldses.org> <20111020091946.GA23773@infradead.org>
	 <20111020102538.GG5444@fieldses.org>
	 <1319154390.2270.52.camel@schurl.linbit>
	 <874nz265tq.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1319194331.5930.9.camel@schurl.linbit>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2011-10-21 at 15:10 +0530, Aneesh Kumar K.V wrote:
> How about the below change. This will require richacl tools change
> also.

>  I made the e_flags 32 bit to make sure we don't take the space
>  needed NFSv4 ACL related flags.

But struct richace_xattr has a hole now.  

There's ample of space left in the 16-bit field; I don't think there is
a need to extend it.  If the need should ever arise, we can still define
a new version of the xattr format.  Also, this change creates a hole in
struct richace_xattr; we can't do that.

> +#define ACE4_SPECIAL_WHO		0x80000000
> +#define ACE4_UNIXID_WHO			0x40000000

Can the ACE4_UNIXID_WHO flag please be removed again?  It isn't needed,
it just creates a mess.

Thanks,
Andreas

