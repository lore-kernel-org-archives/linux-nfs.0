From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.29+ NFS-Server Problem "reconnect_path: npd != pd"
Date: Thu, 21 May 2009 14:12:26 -0400
Message-ID: <1242929546.22947.11.camel@heimdal.trondhjem.org>
References: <20090521142026.GA5566@geggus.net>
	 <1242924599.6687.1.camel@heimdal.trondhjem.org>
	 <20090521165751.GA4428@geggus.net>
	 <1242927133.6687.4.camel@heimdal.trondhjem.org>
	 <gv4463$6fn$1@ultimate100.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36909 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753362AbZEUSM2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 14:12:28 -0400
In-Reply-To: <gv4463$6fn$1@ultimate100.geggus.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-21 at 17:48 +0000, Sven Geggus wrote:
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > So what is the underlying filesystem that you are exporting, and what
> > does your /etc/exports file look like?
> 
> The underlying filesystem is xfs and /etc/exports (unchanged) is here:
> 
> --cut--
> # /etc/exports: the access control list for filesystems which may be exported
> #		to NFS clients.  See exports(5).
> /               192.168.3.2(rw,no_root_squash,async,subtree_check)
> /home/sven	192.168.3.2(rw,no_root_squash,async,subtree_check) 192.168.3.6(rw,no_root_squash,async,subtree_check) 192.168.3.8(rw,no_root_squash,async,subtree_check)
> /home/mp3	192.168.3.2(rw,no_root_squash,async,subtree_check) 192.168.3.6(rw,no_root_squash,async,subtree_check) 192.168.3.8(rw,no_root_squash,async,subtree_check)
> /home/sven/filme 192.168.3.7(ro,async,subtree_check)
> /home/kathi910	192.168.3.7(rw,no_root_squash,async,no_subtree_check)
> --cut--
> 
> 192.168.3.2 is the client which causes the error, I didn't notice the
> error on the other clients, but they are not used that often.
> 
> Especially 192.168.3.7 does seem to work.
> 
> Regards
> 
> Sven
> 

Reforwarding the reply for the benefit of the NFS mailing list. Not
everyone reads lkml...

Trond

