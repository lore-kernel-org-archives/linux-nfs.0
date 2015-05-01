Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47297 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbEARaa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2015 13:30:30 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH, RFC] backchannel overflows
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20150501172345.GB29624@infradead.org>
Date: Fri, 1 May 2015 13:31:11 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <32DAE15A-86A9-401A-B9E1-CBD9777D10CA@oracle.com>
References: <1C0C92C2-FBCF-49D8-BB31-3C23A520B075@oracle.com> <20150429151404.GA12936@infradead.org> <CAHQdGtSzdoymP=8_KQJ1A6iCKe+v3qexsQMvJ3Hx2J+bo96RhA@mail.gmail.com> <20150429173454.GA23284@fieldses.org> <20150430062558.GA25660@infradead.org> <2ED34DBC-D928-4F1F-B5EF-B9F77D8AA075@oracle.com> <20150430143731.GA22038@infradead.org> <CAHQdGtRgEVXidNNYtYf4c3uS0vc6fbm-SZ5AxrY=awXYynmACw@mail.gmail.com> <20CCFEFF-8D28-431C-A1E2-5E42FB42D8FB@oracle.com> <E905ADC8-AB2B-45A7-87FD-0ADF660EA811@oracle.com> <20150501172345.GB29624@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 1, 2015, at 1:23 PM, Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Apr 30, 2015 at 01:41:02PM -0400, Chuck Lever wrote:
>> We discussed this briefly during the Linux NFS town hall meeting.
>> I agree using dynamic slot allocation for TCP is fine, and RPC/RDMA
>> can use simple overprovisioning.
>> 
>> This way the upper layer (NFSv4.1 client) doesn?t have to be aware of
>> limitations in the RPC layer mechanism.
>> 
>> Trond may have an additional concern that I didn?t capture.
> 
> The other option would be to simply overallocate in the transport layer,
> as that is the layer which causes the problem to start with.

That’s exactly what the RDMA backchannel will do.

> That being said, what is the argument for doing any sort of static
> allocation here?  I'm fine with doing fully dynamic allocation if that
> works out fine, but a mixed static / dynamic allocation sounds like a
> nightmare.

RDMA resources must be allocated and pre-registered up front. The
RDMA transport can’t support dynamic slot allocation without adding
a lot more complexity.

The RDMA transport will need to have separate backchannel setup and
destroy methods anyway. So doing dynamic for TCP and overprovision for
RDMA will be simple.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



