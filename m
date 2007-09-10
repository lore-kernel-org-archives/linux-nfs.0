From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Mon, 10 Sep 2007 23:32:25 +0530
Message-ID: <46E586B1.5090601@linux.vnet.ibm.com>
References: <46E121B8.4080105@linux.vnet.ibm.com> <20070907152913.GF24638@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, neilb@suse.de,
	nfs@lists.sourceforge.net, Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760311AbXIJSCl@vger.kernel.org>
In-Reply-To: <20070907152913.GF24638@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

J. Bruce Fields wrote:
> On Fri, Sep 07, 2007 at 03:32:32PM +0530, Kamalesh Babulal wrote:
>   
>> Sep  7 11:42:49 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:945!
>>     
>
> That's the first line of encode_lookup:
>
> 	static int encode_lookup(struct xdr_stream *xdr, const struct qstr *name)
> 	{
> 		int len = name->len;
> 		__be32 *p;
>
> 		RESERVE_SPACE(8 + len);
>
> So len is either very large, or it's just garbage.  Do you know if
> fsstress is trying to do something with a particularly long filename
> here?
>
> --b.
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>   
Hi,

The fsstress creates random file names up to 1024 characters long.

Thanks & regards,
Kamalesh Babulal.
