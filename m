Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63211 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755488Ab1K2U70 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 15:59:26 -0500
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: Sachin Prabhu <sprabhu@redhat.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4: include bitmap in nfsv4 get acl data
Date: Tue, 29 Nov 2011 20:59:03 +0000
Message-ID: <F147FA29-2EBE-4F96-8C88-00E043A01114@netapp.com>
References: <1320477712-1717-1-git-send-email-andros@netapp.com>
 <1322575010.1690.200.camel@sprabhu.fab.redhat.com>
In-Reply-To: <1322575010.1690.200.camel@sprabhu.fab.redhat.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes - thanks for the review. I'll post a new version with a fix.

-->Andy
On Nov 29, 2011, at 8:56 AM, Sachin Prabhu wrote:

> On Sat, 2011-11-05 at 03:21 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> The NFSv4 bitmap size is unbounded: a server can return an arbitrary
>> sized bitmap in an FATTR4_WORD0_ACL request.  Replace using the
>> nfs4_fattr_bitmap_maxsz as a guess to the maximum bitmask returned by a server
>> with the inclusion of the bitmap (xdr length plus bitmasks) and the acl data
>> xdr length to the (cached) acl page data.
>> 
>> This is a general solution to commit e5012d1f "NFSv4.1: update
>> nfs4_fattr_bitmap_maxsz" and fixes hitting a BUG_ON in xdr_shrink_bufhead
>> when getting ACLs.
>> 
>> Cc:stable@kernel.org
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
> 
> I see a problem in case the user decides to pass a buffer which is
> larger than 4K (PAGE_SIZE). In this case, the passed buffer is used as
> is. The data then copied to the buffer will be the buffer which also
> contains a) Bitmap size b) bitmap c) attribute length and finally d)
> attributes. This is not what the user expects.
> 
> static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t buflen)
> {
> ..
> // In case we have buflen > PAGE_SIZE, we will use the existing buffer
>        if (buflen < PAGE_SIZE) {
>        ..
>        } else {
> //Use the existing buffer which was passed.
>                resp_buf = buf;
>                buf_to_pages(buf, buflen, args.acl_pages, &args.acl_pgbase);
>        }
> //Call the rpc calls to obtain the data.
>        ret = nfs4_call_sync(NFS_SERVER(inode)->client, NFS_SERVER(inode), &msg, &args.seq_args, &res.seq_res, 0);
> ..
> //If a buffer was passed with getxattr then
>        if (buf) {
>                ret = -ERANGE;
>                if (res.acl_len > buflen)
>                        goto out_free;
> //If we had to create a localpage, then copy the data from that page to the buffer passed in the arguments
> //Here the memcpy is changed to nfs4_copy_acl() by the patch.
> //In case buflen > PAGE_SIZE, we do not use localpage
>                if (localpage)
>                        nfs4_copy_acl(buf, resp_buf, res.acl_len);
> //Since we had passed a buffer > PAGE size, we use the buffer instead of a localpage.
> // The data wasn't copied over with nfs_copy_acl().
> //The buffer at this point contains additional data such as bitmap size, bitmap data, attribute length 
> //and finally the attributes which were required.
>        }
> ..
> }
> 
> Sachin Prabhu
> 

