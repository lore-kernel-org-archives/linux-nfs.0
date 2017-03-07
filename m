Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36337 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754750AbdCGOW4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 09:22:56 -0500
MIME-Version: 1.0
In-Reply-To: <20170306192301.GB2294@fieldses.org>
References: <20170302160123.30375-1-kolga@netapp.com> <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org> <20170303204747.GE13877@fieldses.org>
 <4B2A2E86-AFC8-49EA-9D53-7A53AD824CF1@netapp.com> <20170303213230.GF13877@fieldses.org>
 <B3F80DA0-B4F8-4628-88C5-E5C047620F17@netapp.com> <20170304021008.GB21609@fieldses.org>
 <924FF7A2-27CD-4848-BD61-748758C2533F@netapp.com> <20170306192301.GB2294@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 7 Mar 2017 09:18:14 -0500
Message-ID: <CAN-5tyGvneN1WFgxmcr0Kx13EZRf-EhJb-EaQp_-+O5i+-0OXA@mail.gmail.com>
Subject: Re: [RFC v1 01/19] Don't copy beyond the end of the file
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-man@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 6, 2017 at 2:23 PM, J. Bruce Fields <bfields@fieldses.org> wrot=
e:
> On Mon, Mar 06, 2017 at 11:27:23AM -0500, Olga Kornievskaia wrote:
>> I don=E2=80=99t see copy_file_range() specifying that 0 means end of the=
 file.
>
> Is there a reason that copy_file_range shouldn't be like read?  (From
> read(2): "On  success,  the number of bytes read is returned (zero
> indicates end of file)".

The only thing I can think of is the fact that copy_file_range() does
write too. And return 0 from the write is not expected/allowed (except
when input count was 0)?

> I haven't checked, but suspect that's already true of the
> implementations we have.
>
> Also, from copy_file_range():
>
>         EINVAL Requested  range  extends beyond the end of the source
>                 file; or the flags argument is not 0.
>
> Some filesystems do this, some don't; I think the man page should make
> it clear that this behavior is not required.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
