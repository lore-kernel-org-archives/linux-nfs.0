Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35913 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073Ab2DQQQd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 12:16:33 -0400
Received: by vcqp1 with SMTP id p1so4219494vcq.19
        for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 09:16:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334679223.2703.15.camel@lade.trondhjem.org>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
	<1334004744-31842-15-git-send-email-iisaman@netapp.com>
	<1334608102.2879.37.camel@lade.trondhjem.org>
	<CADnza467ROBp0-=Qgq5DwSK=Zu5Vyk5i1v1qFN2aMbKXDWdT=A@mail.gmail.com>
	<1334679223.2703.15.camel@lade.trondhjem.org>
Date: Tue, 17 Apr 2012 12:16:32 -0400
Message-ID: <CADnza46wJCykVgCh=3C=9MjZ4i-NLW1HTaDfmw4AMf9OQOj6Jw@mail.gmail.com>
Subject: Re: [PATCH 14/26] NFS: merge _full and _partial read rpc_ops
From: Fred Isaman <faisaman4@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 17, 2012 at 12:13 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-04-17 at 11:37 -0400, Fred Isaman wrote:
>> On Mon, Apr 16, 2012 at 4:28 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> > On Mon, 2012-04-09 at 16:52 -0400, Fred Isaman wrote:
>> >> @@ -64,10 +80,16 @@ void nfs_readhdr_free(struct nfs_pgio_header *hdr)
>> >>
>> >>  void nfs_readdata_release(struct nfs_read_data *rdata)
>> >>  {
>> >> +     struct nfs_pgio_header *hdr = rdata->header;
>> >> +
>> >>       put_nfs_open_context(rdata->args.context);
>> >>       if (rdata->pages.pagevec != rdata->pages.page_array)
>> >>               kfree(rdata->pages.pagevec);
>> >> -     nfs_readhdr_free(rdata->header);
>> >> +     if (container_of(hdr, struct nfs_read_header, header) !=
>> >> +         container_of(rdata, struct nfs_read_header, rpc_data))
>> >> +             kfree(rdata);
>> >
>> > This looks unnecessarily complicated. How about
>> >
>> >        if (rdata != &hdr->rpc_data)
>> >                kfree(rdata);
>> >
>>
>> That won't work.  There is no hdr->rpc_data.
>
> Doh! Make that
>
>        struct nfs_read_header *read_header = container_of(hdr, struct....);
>
>        if (rdata != &read_header->rpc_data)
>                kfree(rdata);
>
> The reason for preferring the above line is that I can trivially see
> that the reason why I don't want to do the kfree() is because I'm
> pointing at a field inside the read_header.
>

OK.

Fred
