Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:40748 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753223Ab1JFDo5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Oct 2011 23:44:57 -0400
Subject: Re: [nfsv4] back channel flags, CREATE_SESSION, BIND_CONN_TO_SESSION
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Matt W. Benjamin" <matt@linuxbox.com>
Cc: nfsv4 <nfsv4@ietf.org>, linux-nfs <linux-nfs@vger.kernel.org>,
        nfs-ganesha-devel <nfs-ganesha-devel@lists.sourceforge.net>
Date: Wed, 05 Oct 2011 23:44:56 -0400
In-Reply-To: <1317871693.14305.5.camel@lade.trondhjem.org>
References: <800236997.158.1317856908314.JavaMail.root@thunderbeast.private.linuxbox.com>
	 <1317871693.14305.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1317872696.14918.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-10-05 at 23:28 -0400, Trond Myklebust wrote: 
> On Wed, 2011-10-05 at 19:21 -0400, Matt W. Benjamin wrote: 
> > Currently, the Linux and I believe also the CITI Windows client always propose channels in both directions.  The Linux mainline Linux client doesn't know how to BIND_CONN_TO_SESSION, so trivially it won't negotiate any back channel if a server didn't agree to both directions today, either.  I've experimentally implemented a "fallback" model in a Linux client and (partly in a) Ganesha server.  I'd appreciate any feedback on the idea.
> 
> Yep. As I said, why should we bother adding support for servers that
> don't? I can function perfectly well without pNFS support or delegation
> support in such a case. Performance will suck, but why do I care?

To put it in more basic terms: what you are proposing will add
development costs to the client and and an extra code burden to maintain
long term. So what is in it for me?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

