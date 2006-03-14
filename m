From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sunrpc svc: be quieter
Date: Tue, 14 Mar 2006 21:21:04 +0000
Message-ID: <441733C0.5040605@gentoo.org>
References: <20060305005532.5E7A0870504@zog.reactivated.net>	 <Pine.LNX.4.61.0603051451590.30115@yvahk01.tjqt.qr> <1141678330.31680.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, neilb@cse.unsw.edu.au,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	okir@monad.swb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932457AbWCNVMh@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <1141678330.31680.13.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond,

Trond Myklebust wrote:
> They are probably trying to ping the server with a NULL procedure call
> to test for service availability. We should allow that particular
> usage...

Thanks, that sounds likely. Can you give some hints as to how a NULL 
procedure call might appear? Would testing for prog==0 and/or proc==0 be 
appropriate?

Daniel
