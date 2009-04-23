From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: Client NFS pachtes workflow
Date: Thu, 23 Apr 2009 16:10:09 +0200
Message-ID: <20090423141009.GI57877@fit.vutbr.cz>
References: <20090423123803.GH57877@fit.vutbr.cz> <1240492685.8240.55.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kazi.fit.vutbr.cz ([147.229.8.12]:62668 "EHLO kazi.fit.vutbr.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538AbZDWOKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Apr 2009 10:10:11 -0400
Received: from kazi.fit.vutbr.cz (localhost [127.0.0.1])
	by kazi.fit.vutbr.cz (envelope-from kasparek@fit.vutbr.cz) (8.14.3/8.14.3) with ESMTP id n3NEAAue073934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2009 16:10:10 +0200 (CEST)
Received: (from kasparek@localhost)
	by kazi.fit.vutbr.cz (8.14.3/8.13.1/Submit) id n3NEA9Zj073933
	for linux-nfs@vger.kernel.org; Thu, 23 Apr 2009 16:10:10 +0200 (CEST)
	(envelope-from kasparek@fit.vutbr.cz)
In-Reply-To: <1240492685.8240.55.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 09:18:05AM -0400, Trond Myklebust wrote:
> On Thu, 2009-04-23 at 14:38 +0200, Kasparek Tomas wrote:

> > while searching some more info for my problems with 2.6.27.x & client
> > packet flow & lockd, I tried to find the flow of patches for NFS clients.
> > For older one, there are dierctories in
> > http://www.linux-nfs.org/Linux-2.6.x/ (up to 28-rc9). Does it mean patches
> > in 2.7.27 originated in time after 2.6.27 was out and were included in
> > 28-rc5 (next dir). Some of the patches seem to correct bugs, do they get
> > into 27.x by default or is it necessary to ask somewhere (GregKH)? 
> 
> The main method of tracking patches is rather through the git tree. The
> patches on client.linux-nfs.org are only being sporadically updated.
> However, yes, the patches in the 2.6.27 subdir are meant to be applied
> to 2.6.27. Some of the bugfixes will find their way into the -stable
> series, but not all (it depends on how serious the bug is, and how
> intrusive the fix is).

Ok, will try to play with git and for my troubles will try to build a
kernel with these patches to see if anything (lockd or floods) works better.

Thanks.

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, L127       Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 1, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  jabber: tomas.kasparek-2ASvDZBniIelVyrhU4qvOw@public.gmane.org
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC

