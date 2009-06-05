From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Link performance over NFS degraded in RHEL5. -- was :
	Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Date: Fri, 5 Jun 2009 12:05:44 -0400
Message-ID: <20090605160544.GE10975@fieldses.org>
References: <1243963631.4868.124.camel@heimdal.trondhjem.org> <18982.41770.293636.786518@fisica.ufpr.br> <1244049027.5603.5.camel@heimdal.trondhjem.org> <1244138698.5203.59.camel@heimdal.trondhjem.org> <OF37FCED66.33F08949-ON852575CB.006DE109-852575CB.0071CFBD@us.ibm.com> <4A2902E6.2080006@RedHat.com> <4A29144A.6030405@gmail.com> <4A291DE3.2070105@RedHat.com> <1244209956.5410.33.camel@heimdal.trondhjem.org> <4A29243F.8080008@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Talpey <tmtalpey@gmail.com>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48007 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbZFEQFp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2009 12:05:45 -0400
In-Reply-To: <4A29243F.8080008-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 05, 2009 at 09:57:19AM -0400, Steve Dickson wrote:
> 
> 
> Trond Myklebust wrote:
> > On Fri, 2009-06-05 at 09:30 -0400, Steve Dickson wrote:
> >> Tom Talpey wrote:
> >>> On 6/5/2009 7:35 AM, Steve Dickson wrote:
> >>>> Brian R Cowan wrote:
> >>>>> Trond Myklebust<trond.myklebust@fys.uio.no>  wrote on 06/04/2009
> >>>>> 02:04:58
> >>>>> PM:
> >>>>>
> >>>>>> Did you try turning off write gathering on the server (i.e. add the
> >>>>>> 'no_wdelay' export option)? As I said earlier, that forces a delay of
> >>>>>> 10ms per RPC call, which might explain the FILE_SYNC slowness.
> >>>>> Just tried it, this seems to be a very useful workaround as well. The
> >>>>> FILE_SYNC write calls come back in about the same amount of time as the
> >>>>> write+commit pairs... Speeds up building regardless of the network
> >>>>> filesystem (ClearCase MVFS or straight NFS).
> >>>> Does anybody had the history as to why 'no_wdelay' is an
> >>>> export default?
> >>> Because "wdelay" is a complete crock?
> >>>
> >>> Adding 10ms to every write RPC only helps if there's a steady
> >>> single-file stream arriving at the server. In most other workloads
> >>> it only slows things down.
> >>>
> >>> The better solution is to continue tuning the clients to issue
> >>> writes in a more sequential and less all-or-nothing fashion.
> >>> There are plenty of other less crock-ful things to do in the
> >>> server, too.
> >> Ok... So do you think removing it as a default would cause
> >> any regressions?
> > 
> > It might for NFSv2 clients, since they don't have the option of using
> > unstable writes. I'd therefore prefer a kernel solution that makes write
> > gathering an NFSv2 only feature.
> Sounds good to me! ;-)

Patch welcomed.--b.
