Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:46040 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab0IMP1n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 11:27:43 -0400
Received: by bwz11 with SMTP id 11so4567957bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 08:27:42 -0700 (PDT)
In-Reply-To: <20100913150700.GA3920@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-8-git-send-email-iisaman@netapp.com>
	<20100913150700.GA3920@infradead.org>
Date: Mon, 13 Sep 2010 08:27:41 -0700
Message-ID: <AANLkTi=MqaawFvKK1SmnZkojchGuH60UBzsZ5p27cXo5@mail.gmail.com>
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
From: Fred Isaman <iisaman@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 13, 2010 at 8:07 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, Sep 02, 2010 at 02:00:13PM -0400, Fred Isaman wrote:
>>  static struct pnfs_layoutdriver_type *
>>  find_pnfs_driver(u32 id) {
>> -     return NULL;
>> +     struct  pnfs_layoutdriver_type *local;
>> +
>> +     spin_lock(&pnfs_spinlock);
>> +     local = find_pnfs_driver_locked(id);
>> +     spin_unlock(&pnfs_spinlock);
>> +     return local;
>
> What about refcounting the structure?
>

The structure is pretty tightly tied to the lifetime of the driver
module.  It seems like grabbing a reference on the module (which as
Trond pointed out needs to be done) is enough.


>> +     spin_lock(&pnfs_spinlock);
>> +     if (!find_pnfs_driver_locked(ld_type->id)) {
>> +             list_add(&ld_type->pnfs_tblid, &pnfs_modules_tbl);
>> +             status = 0;
>> +             dprintk("%s Registering id:%u name:%s\n", __func__, ld_type->id,
>> +                     ld_type->name);
>> +     } else
>> +             printk(KERN_ERR "%s Module with id %d already loaded!\n",
>> +                     __func__, ld_type->id);
>> +     spin_unlock(&pnfs_spinlock);
>
> In other places we generally don't bother doing these checks, so for
> pnfs with just three clients it's even more poinless.
>

But they certainly don't hurt.  If it would prevent inclusion in
mainline, I'll take out the check, but intentionally introducing
potential bugs just because its done in other places seems like a poor
argument.

Fred

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
