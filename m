Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:41170 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbaDUMpe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 08:45:34 -0400
Received: by mail-qg0-f44.google.com with SMTP id q108so1191982qgd.31
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 05:45:33 -0700 (PDT)
Message-ID: <535512EB.60708@gmail.com>
Date: Mon, 21 Apr 2014 08:45:31 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 02/17] NFS: Create a common results structure for reads
 and writes
References: <1397768981-12856-1-git-send-email-Anna.Schumaker@Netapp.com> <1397768981-12856-3-git-send-email-Anna.Schumaker@Netapp.com> <20140418135725.GB20096@infradead.org>
In-Reply-To: <20140418135725.GB20096@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/18/2014 09:57 AM, Christoph Hellwig wrote:
>> +struct nfs_pgio_res {
>> +	struct nfs4_sequence_res	seq_res;
>> +	struct nfs_fattr *	fattr;
>> +	struct nfs_writeverf *	verf;		/* used by write */
>> +	const struct nfs_server *server;	/* used by write */
>> +	__u32			count;
>> +	int			eof;		/* used by read */
> Same comment as for the previous patch applies here.  Also maybe
> this should use a union to overlay the read/write only fields?
I thought about a union, but I didn't know if it was worth it for only one or two differing variables.  I can put one in that would make more sense, though.  Thanks!

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

