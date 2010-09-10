From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 10/13] RFC: nfs: client needs to maintain list of inodes
 with active layouts
Date: Fri, 10 Sep 2010 14:18:08 -0700
Message-ID: <AANLkTi=B7cFuXsd0C=hdf_8BSqe+ZdtgKOt64j_LLqf0@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-11-git-send-email-iisaman@netapp.com>
	<1284148768.10062.94.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34071 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab0IJVSK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 17:18:10 -0400
Received: by bwz11 with SMTP id 11so2628551bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 14:18:08 -0700 (PDT)
In-Reply-To: <1284148768.10062.94.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 10, 2010 at 12:59 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>
>> +static inline struct nfs_server *
>> +PNFS_NFS_SERVER(struct pnfs_layout_hdr *lo)
>> +{
>> + =A0 =A0 return NFS_SERVER(lo->inode);
>> +}
>> +
>
> Why do we need this?

OK, it is gone.

=46red

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
