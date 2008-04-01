From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Tue, 01 Apr 2008 18:48:58 -0400
Message-ID: <47F2BBDA.3080207@RedHat.com>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759592AbYDAWyr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2008 18:54:47 -0400
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C59D349C-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Anirban Sinha wrote:
> Hi:
> 
> I am using a system where we do not use the /proc/nfs/nfsd filesystem (due to several reasons). I understand that without this filesystem, nfsutils does not use the "new cache" mechanism. However, a nfsd restart operation should still be functional. However, when I try doing this manually, I get the following error: 
> 
> root:my_node:/etc/rc.d/init.d# /sbin/service nfs restart
> Shutting down NFS mountd:                                  [  OK  ]
> Shutting down NFS daemon:                                  [FAILED]
> Shutting down NFS services:                                [  OK  ]
> Starting NFS services:                                     [  OK  ]
> Starting NFS daemon:                                       [FAILED]
> Starting NFS mountd:                                       [  OK  ]
This seems to work with both a 2.6.18 kernel (using nfs-utils-1.0.9) and
a 2.6.25 kernel (using nfs-utils-1.1.2-1).
What version of nfs-utils are you using?

> I am using kernel version 2.6.17.7. 
This is a pretty old kernel... any chance of upgrading it?

steved.
