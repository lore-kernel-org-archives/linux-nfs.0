Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailuogwhop.emc.com ([168.159.213.141]:44813 "EHLO
	mailuogwhop.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172AbaCCTzA convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 14:55:00 -0500
From: "faibish, sorin" <faibish_sorin@emc.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shirley Ma <shirley.ma@oracle.com>,
        Wendy Cheng <s.wendy.cheng@gmail.com>
Date: Mon, 3 Mar 2014 14:54:13 -0500
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
Message-ID: <79E85B7D-5ECC-4A63-BB07-C45A570DA53D@emc.com>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
 <E755E683-C064-4ED3-8448-C61F4E5AF16E@oracle.com>
 <20140303190733.GA4556@infradead.org>
In-Reply-To: <20140303190733.GA4556@infradead.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Sent from my iPad

> On Mar 3, 2014, at 7:09 PM, "Christoph Hellwig" <hch@infradead.org> wrote:
> 
>> On Mon, Mar 03, 2014 at 12:02:33PM -0500, Chuck Lever wrote:
>> All HCAs in 3.13 (and rxe) can support either MTHCA_FMR or FRMR or both. Wendy?s HCA supports only ALLPHYSICAL.
> 
> Is Wendy planning to submit her HCA driver ASAP?  If not there's not
> reason to keep ALLPHYSICAL either.
I second Christoph. Legacy is good as long as there are users of Linux with the legacy server. I would say that the only reason to keep it is if Linux server will support it. Same we apply to Lustre client in kernel.

./Sorin

> 
>> Does it make sense to deprecate then remove the registration modes in the first list?
> 
> Yes.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
