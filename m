From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Date: Mon, 1 Jun 2009 18:30:44 -0400
Message-ID: <20090601223044.GG5950@fieldses.org>
References: <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com> <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org> <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com> <1243615595.7155.48.camel@heimdal.trondhjem.org> <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com> <1243618500.7155.56.camel@heimdal.trondhjem.org> <ac442c870905291722x1ec811b2sda997d464898fcda@mail.gmail.com> <1243686363.5209.16.camel@heimdal.trondhjem.org> <ac442c870905300602v6950ec42y5195d2d6ea7dd4c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Brian R Cowan <brcowan@us.ibm.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Greg Banks <gnb-xTcybq6BZ68@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38441 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbZFAWap (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2009 18:30:45 -0400
In-Reply-To: <ac442c870905300602v6950ec42y5195d2d6ea7dd4c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 30, 2009 at 11:02:47PM +1000, Greg Banks wrote:
> On Sat, May 30, 2009 at 10:26 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Sat, 2009-05-30 at 10:22 +1000, Greg Banks wrote:
> >> On Sat, May 30, 2009 at 3:35 AM, Trond Myklebust
> >> <trond.myklebust@fys.uio.no> wrote:
> >> > On Fri, 2009-05-29 at 13:25 -0400, Brian R Cowan wrote:
> >> >>
> >>
> >
> > Firstly, the server only uses O_SYNC if you turn off write gathering
> > (a.k.a. the 'wdelay' option). The default behaviour for the Linux nfs
> > server is to always try write gathering and hence no O_SYNC.
> 
> Well, write gathering is a total crock that AFAICS only helps
> single-file writes on NFSv2.  For today's workloads all it does is
> provide a hotspot on the two global variables that track writes in an
> attempt to gather them.  Back when I worked on a server product,
> no_wdelay was one of the standard options for new exports.

Should be a simple nfs-utils patch to change the default.

--b.

> 
> > Secondly, even if it were the case, then this does not justify changing
> > the client behaviour.
> 
> I totally agree, it was just an observation.
> 
> In any case, as Christoph points out, the ext3 performance difference
> makes an unstable WRITE+COMMIT slower than a stable WRITE, and you
> already assumed that.
> 
> -- 
> Greg.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
