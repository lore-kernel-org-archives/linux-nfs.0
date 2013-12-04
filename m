Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756Ab3LDViG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 16:38:06 -0500
Date: Wed, 4 Dec 2013 16:38:04 -0500
From: Dr Fields James Bruce <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Antti =?utf-8?B?VMO2bmt5csOk?= <daedalus@pingtimeout.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
Message-ID: <20131204213804.GC19452@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
 <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
 <529CF322.4080701@pingtimeout.net>
 <20131203204806.GA2648@fieldses.org>
 <20131203212210.GC2648@fieldses.org>
 <529ED1C8.70208@pingtimeout.net>
 <20131204154104.GB14646@fieldses.org>
 <529F943D.30004@pingtimeout.net>
 <20131204210356.GA19452@fieldses.org>
 <22997028-AB15-4D61-A263-011867EE7512@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <22997028-AB15-4D61-A263-011867EE7512@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 04:22:48PM -0500, Trond Myklebust wrote:
> 
> On Dec 4, 2013, at 16:03, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> 
> > On Wed, Dec 04, 2013 at 10:44:45PM +0200, Antti Tönkyrä wrote:
> > 
> >>>> http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap
> > 
> > And I see something I'd overlooked before: the client is sending the
> > later opens with the same open owner and sequence id.  But NFS4ERR_IO is
> > a seqid-mutating error.  So now I think this probably *is* a client
> > bug....
> 
> Umm… Yes and no. The client should be able to recover when it discovers that the seqid is out of sync.
>
> That said, I see that we do
> 
>        status = decode_op_hdr(xdr, OP_OPEN);
>         if (status != -EIO)
>                 nfs_increment_open_seqid(status, res->seqid);
> 
> and since NFS4ERR_IO == EIO, that means we skip the seqid update when you send us NFS4ERR_IO.

Oh, OK.  Maybe decode_op_hdr could use -NFS4ERR_BADXDR for the two
decoding errors it catches and eliminate the need for this special -EIO
case?

I think NFS4ERR_IO is a legal error for these operations.  (Even if the
server should have returned something else in this case.)

--b.
