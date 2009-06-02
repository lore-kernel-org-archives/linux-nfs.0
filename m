From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Tue, 02 Jun 2009 13:27:11 -0400
Message-ID: <1243963631.4868.124.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
	 <1243618500.7155.56.camel@heimdal.trondhjem.org>
	 <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com>
	 <1243686363.5209.16.camel@heimdal.trondhjem.org>
	 <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
	 <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>, Brian R Cowan <brcowan@us.ibm.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:45796 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686AbZFBR1T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 13:27:19 -0400
In-Reply-To: <BA67D2A4-1752-4789-ADB9-D1B3C6D197F6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-02 at 11:00 -0400, Chuck Lever wrote:
> On May 30, 2009, at 9:02 AM, Greg Banks wrote:
> > On Sat, May 30, 2009 at 10:26 PM, Trond Myklebust
> > <trond.myklebust@fys.uio.no> wrote:
> >> On Sat, 2009-05-30 at 10:22 +1000, Greg Banks wrote:
> >>> On Sat, May 30, 2009 at 3:35 AM, Trond Myklebust
> >>> <trond.myklebust@fys.uio.no> wrote:
> >>>> On Fri, 2009-05-29 at 13:25 -0400, Brian R Cowan wrote:
> >>>>>
> >>>
> >>
> >> Firstly, the server only uses O_SYNC if you turn off write gathering
> >> (a.k.a. the 'wdelay' option). The default behaviour for the Linux nfs
> >> server is to always try write gathering and hence no O_SYNC.
> >
> > Well, write gathering is a total crock that AFAICS only helps
> > single-file writes on NFSv2.  For today's workloads all it does is
> > provide a hotspot on the two global variables that track writes in an
> > attempt to gather them.  Back when I worked on a server product,
> > no_wdelay was one of the standard options for new exports.
> 
> Really?  Even for NFSv3/4 FILE_SYNC?  I can understand that it  
> wouldn't have any real effect on UNSTABLE.

The question is why would a sensible client ever want to send more than
1 NFSv3 write with FILE_SYNC? If you need to send multiple writes in
parallel to the same file, then it makes much more sense to use
UNSTABLE.

Write gathering relies on waiting an arbitrary length of time in order
to see if someone is going to send another write. The protocol offers no
guidance as to how long that wait should be, and so (at least on the
Linux server) we've coded in a hard wait of 10ms if and only if we see
that something else has the file open for writing.
One problem with the Linux implementation is that the "something else"
could be another nfs server thread that happens to be in nfsd_write(),
however it could also be another open NFSv4 stateid, or a NLM lock, or a
local process that has the file open for writing.
Another problem is that the nfs server keeps a record of the last file
that was accessed, and also waits if it sees you are writing again to
that same file. Of course it has no idea if this is truly a parallel
write, or if it just happens that you are writing again to the same file
using O_SYNC...

  Trond

