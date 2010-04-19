From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/24] Reduce the stack foot print of the NFS client
Date: Mon, 19 Apr 2010 19:37:20 -0400
Message-ID: <4BCCE930.9030007@oracle.com>
References: <1271449882-8580-1-git-send-email-Trond.Myklebust@netapp.com>	 <4BCCCE84.3050109@oracle.com> <1271719778.25129.73.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:25792 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671Ab0DSXjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 19:39:06 -0400
In-Reply-To: <1271719778.25129.73.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/19/2010 07:29 PM, Trond Myklebust wrote:
> On Mon, 2010-04-19 at 17:43 -0400, Chuck Lever wrote:
>> On 04/16/2010 04:30 PM, Trond Myklebust wrote:
>>> The following patch series aims to significantly reduce the stack foot
>>> print of the NFS client by dynamically allocating the struct nfs_fattr
>>> and struct nfs_fh.
>>
>> Random comments:
>>
>> 1.  There's an open-coded kzalloc of an nfs_fh in nfs_get_sb.  This can
>> be replaced with nfs_alloc_fh().
>
> Added a clean up patch to do this.
>
>> 2.  root_nfs_get_handle allocates an nfs_fh on the stack.  This can be
>> replaced with nfs_alloc_fh().
>
> I suppose, although there will never be any danger of anyone calling
> this function from any unexpected contexts. Anyhow, added a patch.
>
>> 3.  There is an unneeded nfs_fattr_init() call in nfs_probe_fsinfo().  I
>> didn't look for others that are similarly made obsolete.
>
> Fixed.
>
>> 4.  Where ever you have "if (fattr == NULL) goto out;" (and similarly
>> for filehandles) you could add "unlikely()" to improve branch prediction
>> slightly.
>
> No. While I agree that it is unlikely to fail, I prefer _not_ to have to
> wade through all these likely()/unlikely() markups in order to read the
> code. A quick perusal of other examples shows that I'm not alone in that
> preference.
>
>> 5.  The documenting comment before nfs_do_refmount() is out of date.
>
> Fixed.

I forgot to add this in my reply to the cover letter of the original series:

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

   and/or

Tested-by: Chuck Lever <chuck.lever@oracle.com>

-- 
chuck[dot]lever[at]oracle[dot]com
