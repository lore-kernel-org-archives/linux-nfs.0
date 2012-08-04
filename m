Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25303 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199Ab2HDPJJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Aug 2012 11:09:09 -0400
Message-ID: <501D3B12.5040105@netapp.com>
Date: Sat, 04 Aug 2012 11:09:06 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: William Dauchy <wdauchy@gmail.com>
CC: David Howells <dhowells@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
Subject: Re: nfs_idmap_legacy_upcall
References: <CAJ75kXa9PRJMHXfTHGLxnXUAMwnA9RD5G+cjHnOdk8SE_hbsZQ@mail.gmail.com> <866.1343987269@warthog.procyon.org.uk> <CAJ75kXaYgxiRZnFzZLXSj61EXOEVNsPcy70etkLRhEpy9AWDnA@mail.gmail.com> <CAJ75kXbFTm3+v9OJTcKsO+nmn6q0CbSZniT0MkP+oUh7f_sZ0Q@mail.gmail.com>
In-Reply-To: <CAJ75kXbFTm3+v9OJTcKsO+nmn6q0CbSZniT0MkP+oUh7f_sZ0Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/04/2012 06:26 AM, William Dauchy wrote:
> On Fri, Aug 3, 2012 at 2:08 PM, William Dauchy <wdauchy@gmail.com> wrote:
>> 4697bd5:NFSv4: Fix a race in the net namespace mount notification
> 
> this one didn't help. still getting a wait_for_key_construction oops.
> I opened a second thread about it, first thinking this was two
> different issues
> will dig it a bit more
> 

What are you doing to reproduce this?  I'm having bash run mount / unmount in a loop, but so far I haven't seen the oops.  Also, are you using kerberos?

- Bryan
