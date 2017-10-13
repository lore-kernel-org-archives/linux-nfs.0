Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20337 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753415AbdJMONW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Oct 2017 10:13:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20171012121706.GC5957@stefanha-x1.localdomain>
Date: Fri, 13 Oct 2017 10:13:18 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <00E6726C-D32F-4C34-B809-F3F3CCCF22D5@oracle.com>
References: <20171005200835.GA31525@stefanha-x1.localdomain> <2BCB0D75-EF18-4463-BEB4-D09005DAE86B@oracle.com> <20171012121706.GC5957@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 12, 2017, at 8:17 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> On Thu, Oct 05, 2017 at 04:53:07PM -0400, Chuck Lever wrote:
>>> On Oct 5, 2017, at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
>> An unchanging public reference to a specification of VSOCK is
>> important to cite. If you can't find one, you'll have to explain
>> why in the document. If the VSOCK specification is not an IETF
>> document, it will have to be an Informative reference, and this
>> I-D will also have to be Informative.
> 
> There is no formal specification.  VMware has published developer
> documentation that explains the use of VSOCK in the context of VMware
> products.

If there is nothing else, this is the most appropriate reference
to cite. It provides a description of the technology made by the
agent who invented and ultimately controls it (we believe: it
may be that someone else did, and VMware is just taking credit;
I think we need to know that too).

You should contact VMware to see if they have anything more, and
to ask if they already have NFS on VSOCK. Let them know you are
submitting standards in this area.


> I will submit a vsock(7) man page to the Linux man-pages project
> (similar to ip(7), tcp(7), etc).  It will document the semantics of the
> AF_VSOCK address family.  Maybe this can serve as a reference?

The IESG will ultimately decide, but IMO citing a man page that
you wrote would not be adequate unless you yourself invented the
VSOCK technology.


--
Chuck Lever



