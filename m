Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15530 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756118Ab1DLSbb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2011 14:31:31 -0400
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jiri Slaby <jslaby@suse.cz>
Cc: Bryan Schumaker <bjschuma@netapp.com>, Jiri Slaby <jirislaby@gmail.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4DA4946D.5020403@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>
	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>
	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>
	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>
	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 12 Apr 2011 14:31:28 -0400
Message-ID: <1302633088.4801.48.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-04-12 at 20:05 +0200, Jiri Slaby wrote:
> On 04/12/2011 07:41 PM, Bryan Schumaker wrote:
> > On 04/11/2011 05:08 PM, Jiri Slaby wrote:
> >>
> >> Sorry for an extra message. I've just found out that there appears
> >> messages in dmesg:
> >> [   58.656048] RPC: AUTH_GSS upcall timed out.
> >> [   58.656050] Please check user daemon is running.
> >> [   88.656065] RPC: AUTH_GSS upcall timed out.
> >> [   88.656068] Please check user daemon is running.
> >> [  118.656077] RPC: AUTH_GSS upcall timed out.
> >> [  118.656080] Please check user daemon is running.
> >> [  148.656049] RPC: AUTH_GSS upcall timed out.
> >> [  148.656052] Please check user daemon is running.
> >> [  178.656046] RPC: AUTH_GSS upcall timed out.
> >> [  178.656049] Please check user daemon is running.
> >>
> >>
> >> I instrumented the code and it's stuck with trying RPC_AUTH_GSS_KRB5.
> >>
> >> I don't use GSS at all.
> >>
> >> regards,
> > 
> > Does this patch help?
> > 
> > - Bryan
> > 
> > 
> > 
> > There can be an infinite loop if gss_create_upcall() is called without
> > the userspace program running.  To prevent this, we return -EACCES if
> > we notice that pipe_version hasn't changed (indicating that the pipe
> > has not been opened).
> 
> Yes, it fixes the problem. But it waits 15s before it times out. This is
> inacceptable for automounted NFS dirs.

I'm still confused as to why you are hitting it at all. In the normal
autonegotiation case, the client should be trying to use AUTH_SYS first
and then trying rpcsec_gss if and only if that fails.

Are you really exporting a filesystem using AUTH_NULL as the only
supported flavour?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

