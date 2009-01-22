From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 10:27:47 -0500
Message-ID: <49789073.1080200@RedHat.com>
References: <4970B451.4080201@RedHat.com>		<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>		<497757D1.7090908@RedHat.com>		<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>		<49777988.6010401@RedHat.com>		<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>		<4977A385.8000406@melbourne.sgi.com>		<1232578570.7692.96.camel@heimdal.trondhjem.org>		<4977AB86.4030603@melbourne.sgi.com>	<1232581675.7692.121.camel@heimdal.trondhjem.org> <4977D431.1020906@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38080 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753242AbZAVPaR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jan 2009 10:30:17 -0500
In-Reply-To: <4977D431.1020906-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greg Banks wrote:
> 
> These are two separate proposals between which we're trying to find some
> commonality.
I agree.. a common effort does make the most sense... imho...

> 
> In my proposal, the dprintk()s remain designed primarily for humans
> (support staff or kernel developers) to read in conjunction with the
> correct source code, but control is made fine-grain to make the
> mechanism more controllable.  This can be done regardless of whether
> trace points are involved and regardless of whether we attempt to
> support scripts.
I would think it the "fine-grain control mechanism" could also manage
trace points as well, true?

> 
> Changing dprintk() to add a trace point is just a way to get some trace
> points with strictly minimum changes to callsites.
I'm not sure this would be a good idea since, as Trond or Chuck pointed out,
there is really not rhyme or reason on where the dprintks live today... 

> 
> Replacing dprintk()s with new trace points has more or less the same
> result but means more futzing with callsites.
Well not if the replacements are well thought out and designed, since
there does not have 1-to-1 replacement... 
 
> 
> The maintenance problem of correlating any kind of instrumentation point
> in kernel code with scripts living out in userspace exists regardless of
> how you choose to implement the instrumentation.
> 
+1

steved.
