Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f181.google.com ([74.125.82.181]:37328 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbaIQNkx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 09:40:53 -0400
Received: by mail-we0-f181.google.com with SMTP id w62so1446716wes.40
        for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 06:40:52 -0700 (PDT)
Message-ID: <54198F61.6030704@gmail.com>
Date: Wed, 17 Sep 2014 16:40:49 +0300
From: Benny Halevy <bhalevy.lists@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@lst.de>, Boaz Harrosh <boaz@plexistor.com>
CC: Peng Tao <tao.peng@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs41: change PNFS_LAYOUTRET_ON_SETATTR to only return
 on truncation to smaller size
References: <1410491050-12858-1-git-send-email-tao.peng@primarydata.com> <541572BE.6000504@plexistor.com> <20140914164328.GA13467@lst.de>
In-Reply-To: <20140914164328.GA13467@lst.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 09/14/2014 07:43 PM, Christoph Hellwig wrote:
> On Sun, Sep 14, 2014 at 01:49:34PM +0300, Boaz Harrosh wrote:
>> This is in violation of the pnf-objects draft.
> Ithought that's an RFC by now? :)
>
>> We are obliged
>> on chown to return layouts because of how the CAPs work, they
>> have an embedded CAPs version which might increment when chown
>> is changed, and also the credential keys. Which means that using
>> the old layout will return an E_ACCESS from the OSD.
> This is a good enough argument to just split the flags into one
> for chown and one for truncate.  Can you confirm that any other
> setattr but a truncate to a smaller size or chown is fine with
> your interpretation of RFC5664?
>
>> But..
>>
>> I will agree with this patch. The above is true in an OSD
>> protocol higher then NO_SEC. But none of the current implementation
>> support anything other then NO_SEC.
>>
>> Second also with none-NO_SEC once a client does a chown the server
>> needs to RECALL all other clients, so as Peng says above the Server
>> should/can also recall from us.
>>
>> But some good sole needs to make an errata at the RFC draft so to
>> explain.
> I'd rather not violate the existing RFC unless we have a good reason for it
> and an errata out.  Having a flag to return on chown for the object layout
> seems like the easier way to go forward.

Ack

Benny

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

