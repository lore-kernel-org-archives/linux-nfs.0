Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20510 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754793Ab1DLSip convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 14:38:45 -0400
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Bryan Schumaker <bjschuma@netapp.com>, Jiri Slaby <jirislaby@gmail.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4DA49B49.1020005@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>
	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>
	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>
	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz>
	 <1302633088.4801.48.camel@lade.trondhjem.org>  <4DA49B49.1020005@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Apr 2011 14:38:42 -0400
Message-ID: <1302633522.4801.49.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-12 at 20:34 +0200, Jiri Slaby wrote:
> On 04/12/2011 08:31 PM, Trond Myklebust wrote:
> >> Yes, it fixes the problem. But it waits 15s before it times out. This is
> >> inacceptable for automounted NFS dirs.
> > 
> > I'm still confused as to why you are hitting it at all. In the normal
> > autonegotiation case, the client should be trying to use AUTH_SYS first
> > and then trying rpcsec_gss if and only if that fails.
> > 
> > Are you really exporting a filesystem using AUTH_NULL as the only
> > supported flavour?
> 
> I don't know, I connect to a nfs server which is not maintained by me.
> It looks like that. How can I find out?

A wireshark trace of a successful mount would help.
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

