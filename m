From: Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
Date: Mon, 13 Sep 2010 08:16:01 -0700
Message-ID: <AANLkTimDecGjg0GwCshNH0gdN_mr0RqNd=jPTfoPeSCm@mail.gmail.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-9-git-send-email-iisaman@netapp.com>
	<20100913150844.GB3920@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63499 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683Ab0IMPQC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 11:16:02 -0400
Received: by bwz11 with SMTP id 11so4556491bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 08:16:01 -0700 (PDT)
In-Reply-To: <20100913150844.GB3920@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 13, 2010 at 8:08 AM, Christoph Hellwig <hch@infradead.org> =
wrote:
> On Thu, Sep 02, 2010 at 02:00:14PM -0400, Fred Isaman wrote:
>> +static int __init nfs4filelayout_init(void)
>> +{
>> + =A0 =A0 printk(KERN_INFO "%s: NFSv4 File Layout Driver Registering=
=2E..\n",
>> + =A0 =A0 =A0 =A0 =A0 =A0__func__);
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Need to register file_operations struct with global l=
ist to indicate
>> + =A0 =A0 =A0* that NFS4 file layout is a possible pNFS I/O module
>> + =A0 =A0 =A0*/
>> + =A0 =A0 return pnfs_register_layoutdriver(&filelayout_type);
>
> And I thought we were dealing with an UFO detection device here..
>
> Sarcasm aside, this is one of the most pointless and incorrect commen=
ts I've
> seen for a while.
>
>> + =A0 =A0 /* Unregister NFS4 file layout driver with pNFS client*/
>> + =A0 =A0 pnfs_unregister_layoutdriver(&filelayout_type);
>
> This one is not too useful either.
>

OK

=46red

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
