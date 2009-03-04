From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/2] NFSD: fix handling of unsupported nfsv4 ops
Date: Wed, 04 Mar 2009 23:11:55 +0200
Message-ID: <49AEEE9B.2040507@panasas.com>
References: <49A6FD82.6080808@panasas.com> <20090304210200.GG28951@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs mailing list <pnfs@linux-nfs.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4219 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750875AbZCDV1O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 16:27:14 -0500
In-Reply-To: <20090304210200.GG28951@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 04, 2009, 23:02 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Feb 26, 2009 at 12:37:22PM -0800, Benny Halevy wrote:
>> Both patches fix issues I introduced in 2.6.27.
>> The first one is more crucial to get to the 2.6.2{7,8} stable streams
>> but while at it, I'd pull both.
>> This was triggered in connectathon with the Sun OpenSolaris
>> client trying to read extended attrs (when copying a file).
>> This translates to a NFS4 OP_OPENATTR which caused our server to barf.
> 
> Thanks!  But, sorry, somehow I didn't get both of these (probably a
> screwup on my end); would you mind resending?

Just did.

> 
> Also, have you checked to make sure there aren't any other holes in our
> list of operations?

Yup.  OPENATTR was the only hole I found.

Benny

> 
> --b.
> 
>> [PATCH 1/2] NFSD: provide encode routine for OP_OPENATTR
>> [PATCH 2/2] NFSD: return nfsv4 error code nfserr_notsupp rather than nfsv[23]'s nfserr_opnotsupp
>>
>> Benny
