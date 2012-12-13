Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailgw1.uni-kl.de ([131.246.120.220]:33056 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933092Ab2LMOMT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:12:19 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id qBDE6Mk5026328
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Thu, 13 Dec 2012 15:06:22 +0100
Message-ID: <50C9E0DC.8040508@fastmail.fm>
Date: Thu, 13 Dec 2012 15:06:20 +0100
From: Bernd Schubert <bernd.schubert@fastmail.fm>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: 3.5.3: NULL pointer dereference in svc_destroy()
References: <504F380D.3040408@fastmail.fm> <20121205102219.46b22869@corrin.poochiereds.net>
In-Reply-To: <20121205102219.46b22869@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Jeff,

On 12/05/2012 04:22 PM, Jeff Layton wrote:
> Hi Bernd,
>
> Sorry for the late response. I just chased down a similar bug reported
> against Fedora and noticed that you reported the same bug here. In
> fact, there is not a missing svc_get() there since svc_create_pooled
> returns a reference on success. The problem is likely that we're
> calling svc_destroy(nfsd_serv) in the above code, but the pointer is
> not getting NULL'ed out.
>
> The good news is that I believe this is fixed in 3.6 kernels and up...
>
> I have a bit more analysis here if you're interested:
>
>      https://bugzilla.redhat.com/show_bug.cgi?id=848867#c5


thanks for the heads up! I will take a look later on, probably during 
x-mas time. I'm right now just very busy with our project at work to 
finish a release...


Thanks again,
Bernd

