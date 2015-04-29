Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f43.google.com ([209.85.216.43]:40203 "EHLO
	mail-vn0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031690AbbD2O6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 10:58:04 -0400
Received: by vnbg62 with SMTP id g62so3589530vnb.7
        for <linux-nfs@vger.kernel.org>; Wed, 29 Apr 2015 07:58:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
References: <20150428202157.GA23972@infradead.org>
	<1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
Date: Wed, 29 Apr 2015 10:58:03 -0400
Message-ID: <CAHQdGtQBVKPBJA=uwwE1CXi=P=e85kg6EgZaQE_wWHvA=c=Csg@mail.gmail.com>
Subject: Re: [PATCH, RFC] backchannel overflows
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 10:55 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Apr 28, 2015, at 4:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
>
>> Currently the client will just crap out if a CB_NULL comes in at the
>> same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.
>
> Under what circumstances does the server send a CB_NULL while a CB_COMPOUND
> is in flight?
>

I agree with Chuck. Why does knfsd send a CB_NULL at all if the
intention is to send CB_COMPOUND?

Cheers
  Trond
