Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33316 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbGIJ2v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 05:28:51 -0400
Received: by pacws9 with SMTP id ws9so149238075pac.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jul 2015 02:28:51 -0700 (PDT)
Message-ID: <559E3ECA.6000606@gmail.com>
Date: Thu, 09 Jul 2015 17:28:42 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: Re: [PATCH 1/3] nfsd: Set lc_size_chg before ops->proc_layoutcommit
References: <559B3573.4090307@gmail.com> <20150708184431.GB19084@fieldses.org> <20150709080419.GA19291@infradead.org>
In-Reply-To: <20150709080419.GA19291@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 16:04, Christoph Hellwig wrote:
> On Wed, Jul 08, 2015 at 02:44:31PM -0400, J. Bruce Fields wrote:
>> On Tue, Jul 07, 2015 at 10:12:03AM +0800, Kinglong Mee wrote:
>>> After proc_layoutcommit success, i_size_read(inode) always >= new_size.
>>> Just set lc_size_chg before proc_layoutcommit, if proc_layoutcommit
>>> failed, nfsd will skip the lc_size_chg, so it's no harm.
>>
>> Looks right to me, though could probably use an ACK from Christoph.
>>
>> (But looking at the spec I'm confused about how the client is supposed
>> to use this information.)
> 
> I don;t think its possible to use, as there it is inherently racy.
> 
> If the test passes xfstests I'm fine with it.

nfs client just drop this value directly in decode_layoutcommit(),

        if (sizechanged) {
                /* throw away new size */
                p = xdr_inline_decode(xdr, 8);
                if (unlikely(!p))
                        goto out_overflow;
        }

The only problem is after ops->proc_layoutcommit(),  new_size will never
larger than inode's size, at most it is equal to.

        if (new_size > i_size_read(inode)) {
                lcp->lc_size_chg = 1;
                lcp->lc_newsize = new_size;
        } else {
                lcp->lc_size_chg = 0;
        }

thanks,
Kinglong Mee
