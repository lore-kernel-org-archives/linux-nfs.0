Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33393 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754286Ab3LDVXD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 16:23:03 -0500
Received: by mail-ie0-f174.google.com with SMTP id at1so27728823iec.33
        for <linux-nfs@vger.kernel.org>; Wed, 04 Dec 2013 13:23:03 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1812\))
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20131204210356.GA19452@fieldses.org>
Date: Wed, 4 Dec 2013 16:22:48 -0500
Cc: =?windows-1252?Q?Antti_T=F6nkyr=E4?= <daedalus@pingtimeout.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <22997028-AB15-4D61-A263-011867EE7512@primarydata.com>
References: <529CEBC3.8060505@pingtimeout.net> <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com> <529CF322.4080701@pingtimeout.net> <20131203204806.GA2648@fieldses.org> <20131203212210.GC2648@fieldses.org> <529ED1C8.70208@pingtimeout.net> <20131204154104.GB14646@fieldses.org> <529F943D.30004@pingtimeout.net> <20131204210356.GA19452@fieldses.org>
To: Dr Fields James Bruce <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 4, 2013, at 16:03, Dr Fields James Bruce <bfields@fieldses.org> wrote:

> On Wed, Dec 04, 2013 at 10:44:45PM +0200, Antti Tönkyrä wrote:
> 
>>>> http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap
> 
> And I see something I'd overlooked before: the client is sending the
> later opens with the same open owner and sequence id.  But NFS4ERR_IO is
> a seqid-mutating error.  So now I think this probably *is* a client
> bug....

Umm… Yes and no. The client should be able to recover when it discovers that the seqid is out of sync.

That said, I see that we do

       status = decode_op_hdr(xdr, OP_OPEN);
        if (status != -EIO)
                nfs_increment_open_seqid(status, res->seqid);

and since NFS4ERR_IO == EIO, that means we skip the seqid update when you send us NFS4ERR_IO.

Cheers,
  Trond