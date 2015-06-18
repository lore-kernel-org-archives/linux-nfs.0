Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.229]:16123 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751163AbbFRDHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 23:07:38 -0400
Date: Wed, 17 Jun 2015 23:08:19 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [REGRESSION] NFS is creating a hidden port (left over from
 xs_bind() )
Message-ID: <20150617230819.0a11e47a@grimm.local.home>
In-Reply-To: <20150612115038.44e20ccd@gandalf.local.home>
References: <20150611234929.7b48d314@gandalf.local.home>
	<CAHQdGtSyHtMfyVxT=hFY4m6XvM=3mxnZ=ajVJWYNXvYqE0+3zA@mail.gmail.com>
	<1434120035.27504.77.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150612113420.5c114183@gandalf.local.home>
	<20150612115038.44e20ccd@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Jun 2015 11:50:38 -0400
Steven Rostedt <rostedt@goodmis.org> wrote:

> I reverted the following commits:
> 
> c627d31ba0696cbd829437af2be2f2dee3546b1e
> 9e2b9f37760e129cee053cc7b6e7288acc2a7134
> caf4ccd4e88cf2795c927834bc488c8321437586
> 
> And the issue goes away. That is, I watched the port go from
> ESTABLISHED to TIME_WAIT, and then gone, and theirs no hidden port.
> 
> In fact, I watched the port with my portlist.c module, and it
> disappeared there too when it entered the TIME_WAIT state.
> 

I've been running v4.0.5 with the above commits reverted for 5 days
now, and there's still no hidden port appearing.

What's the status on this? Should those commits be reverted or is there
another solution to this bug?

-- Steve
