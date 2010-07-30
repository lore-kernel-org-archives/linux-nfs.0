From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: [PATCH 1/5] nfsd: bypass readahead cache when have struct file
Date: Fri, 30 Jul 2010 16:19:11 +0800
Message-ID: <4C528AFF.5020806@cn.fujitsu.com>
References: <1280442084-17867-1-git-send-email-bfields@redhat.com> <1280442084-17867-2-git-send-email-bfields@redhat.com> <20100730081041.GA4126@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53797 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753959Ab0G3IUW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jul 2010 04:20:22 -0400
In-Reply-To: <20100730081041.GA4126@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> +	} else
>> +		err = nfsd_open_read(rqstp, fhp, offset, vec, vlen, count);
> 
> The callers of nfsd_read are:
> 
> fs/nfsd/nfs3proc.c:     nfserr = nfsd_read(rqstp, &resp->fh, NULL,
> fs/nfsd/nfs4proc.c:     /* no need to check permission - this will be done in nfsd_read() */
> fs/nfsd/nfs4xdr.c:      nfserr = nfsd_read(read->rd_rqstp, read->rd_fhp, read->rd_filp,
> fs/nfsd/nfsproc.c:      nfserr = nfsd_read(rqstp, fh_copy(&resp->fh, &argp->fh), NULL,
> 
> which suggests that we're better off just calling nfsd_open_read
> (possible with a better name) directly from fs/nfsd/nfs3proc.c and
> fs/nfsd/nfsproc.c and nfsd_vfs_read directly from fs/nfsd/nfs4proc.c
> and fs/nfsd/nfs4xdr.c instead of doing this conditional.
> 

  As bruce said, it should not be used for NFSv4. 

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 

-- 
Regards
Bian Naimeng

