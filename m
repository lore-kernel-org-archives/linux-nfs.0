From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Wed, 20 May 2009 17:20:03 -0600
Message-ID: <4A149023.1090504@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com> <4a14106e.48c3f10a.7ce3.0e55@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:24982 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757456AbZETXUD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 19:20:03 -0400
In-Reply-To: <4a14106e.48c3f10a.7ce3.0e55-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> Found it, on the old nfs list:
> http://thread.gmane.org/gmane.linux.nfs/16611
>
>   

Sorry I didn't see this until now... I realize now that we were 
definitely not talking about the same problem. I apologize for not being 
clear. My 'callbacks' are file system grant calls to lockd, not rpc 
calls to/from clients.

Rob Gardner

