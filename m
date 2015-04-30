Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:18192 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbbD3Od1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 10:33:27 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH, RFC] backchannel overflows
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150430062558.GA25660@infradead.org>
Date: Thu, 30 Apr 2015 10:34:02 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com>
References: <20150428202157.GA23972@infradead.org> <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com> <20150429151404.GA12936@infradead.org> <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com> <20150429173454.GA23284@fieldses.org> <20150430062558.GA25660@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 30, 2015, at 2:25 AM, Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Apr 29, 2015 at 01:34:54PM -0400, J. Bruce Fields wrote:
>>> Why does it need to do this? If the client has sent the
>>> BIND_CONN_TO_SESSION (which I believe that knfsd asks for), then the
>>> server knows that this is a bi-directional connection.
>>> The difference between NFSv4 and NFSv4.1 is that the CB_NULL should
>>> almost always be redundant, because the client initiates the
>>> connection and it explicitly tells the server whether or not it is to
>>> be used for the callback channel.
>>> 
>>> The CB_NULL should always be redundant.
>> 
>> I'd be fine with suppressing it.  I think I actually intended to but
>> screwed it up.  (Chuck or somebody convinced me the
>> NFSD4_CB_UP/UNKNOWN/DOWN logic is totally broken but I never got around
>> to fixing it.)
> 
> I've dived into removing CB_NULL, and fixed various major breakage
> in the nfsd callback path. for which I will send you an RFC series ASAP.
> 
> However, even with that I see the "Callback slot table overflowed" from the
> client under load.  I think the problem is the following:
> 
> Between sending the callback response in call_bc_transmit -> xprt_transmit
> and actually releasing the request from rpc_exit_task -> xprt_release ->
> xprt_free_bc_request there is race window, and between and overloaded client
> and a fast connection we can hit this one easily.
> 
> My patch to increase the number of buffers for the backchannel ensures
> this doesn't happen in my setup, but of course I could envinsion a
> theoretical setu where the client is so slow that multiple already
> processed requests might not be returned yet.

I’ve been discussing the possibility of adding more session slots on
the Linux NFS client with jlayton. We think it would be straightforward,
once the workqueue-based NFSD patches are in, to make the backchannel
service into a workqueue. Then it would be a simple matter to increase
the number of session slots.

We haven’t discussed what would be needed on the server side of this
equation, but sounds like it has some deeper problems if it is not
obeying the session slot table limits advertised by the client.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



