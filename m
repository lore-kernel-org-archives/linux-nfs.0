Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:40807 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753506AbbD2PYD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 11:24:03 -0400
Received: by vnbg62 with SMTP id g62so3697699vnb.7
        for <linux-nfs@vger.kernel.org>; Wed, 29 Apr 2015 08:24:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150429151404.GA12936@infradead.org>
References: <20150428202157.GA23972@infradead.org>
	<1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com>
	<20150429151404.GA12936@infradead.org>
Date: Wed, 29 Apr 2015 11:24:02 -0400
Message-ID: <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com>
Subject: Re: [PATCH, RFC] backchannel overflows
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 11:14 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Wed, Apr 29, 2015 at 10:55:10AM -0400, Chuck Lever wrote:
>>
>> On Apr 28, 2015, at 4:21 PM, Christoph Hellwig <hch@infradead.org> wrote:
>>
>> > Currently the client will just crap out if a CB_NULL comes in at the
>> > same time as a slot controlled CB_COMPOUND that includes a CB_SEQUENCE.
>>
>> Under what circumstances does the server send a CB_NULL while a CB_COMPOUND
>> is in flight?
>
> When a client is under heavy loads from fsx or aio-stress, and we lose
> the connection (nfsd4_conn_lost is called) while doing heavy recalls.
>
> xfstests against a server offering pnfs layouts for which the client
> can't reach the storage devices is an easy reproducer.

Why does it need to do this? If the client has sent the
BIND_CONN_TO_SESSION (which I believe that knfsd asks for), then the
server knows that this is a bi-directional connection.
The difference between NFSv4 and NFSv4.1 is that the CB_NULL should
almost always be redundant, because the client initiates the
connection and it explicitly tells the server whether or not it is to
be used for the callback channel.

The CB_NULL should always be redundant.

Trond
