Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0041.hostedemail.com ([216.40.44.41]:47440 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750832AbbFLPxj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 11:53:39 -0400
Date: Fri, 12 Jun 2015 11:53:36 -0400
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
Message-ID: <20150612115336.35f37c34@gandalf.local.home>
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

> On Fri, 12 Jun 2015 11:34:20 -0400
> Steven Rostedt <rostedt@goodmis.org> wrote:
> 

> 
> And the issue goes away. That is, I watched the port go from
> ESTABLISHED to TIME_WAIT, and then gone, and theirs no hidden port.
> 

s/theirs/there's/

Time to go back to grammar school. :-p

-- Steve
