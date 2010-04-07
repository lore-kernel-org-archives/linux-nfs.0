From: Bernd Schubert <bernd.schubert@fastmail.fm>
Subject: Re: nfs + Reiser4
Date: Thu, 8 Apr 2010 00:44:38 +0200
Message-ID: <201004080044.38451.bernd.schubert@fastmail.fm>
References: <op.vaq49joctxpshh@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45805 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab0DGWpG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 18:45:06 -0400
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Nzdzc-0002uO-8o
	for linux-nfs@vger.kernel.org; Thu, 08 Apr 2010 08:45:04 +1000
In-Reply-To: <op.vaq49joctxpshh-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 06 April 2010, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote:
> Hi,
> 
> I am having serious headaches using nfs between a reiser4 server and arm
> client.
> Both on 2.6.29 vintage kernels.
> 
> Files are constantly getting out of sync.
> 
> Example :
> 
> boot ARM via nfs
> edit lighttpd.conf on ARM
> check edit is visible on server. OK
> 
> reboot ARM
> check file : reverted to an earlier state.
> check server: edited version still showing.
> 
> 
> This is just one example of serious userablity issues. I have also seen a
> revert 10s later reopening the same file on the ARM.
> 
> Is this possibly related to R4 + nfs ?

Reminds me about an old bug report I wrote and which nobody ever cared about:

http://article.gmane.org/gmane.linux.nfs/9867/match=


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

