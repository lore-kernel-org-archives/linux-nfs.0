From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 4/4] nfs-utils: add initial tests for statd that run via
 "make check"
Date: Fri, 8 Jan 2010 11:56:51 -0500
Message-ID: <20100108115651.7a84a3c5@tlielax.poochiereds.net>
References: <1262962563-5554-1-git-send-email-jlayton@redhat.com>
	<1262962563-5554-5-git-send-email-jlayton@redhat.com>
	<70DEDD50-4AC5-4377-B5FA-A1FBCD92EBF3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28114 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709Ab0AHQ46 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 11:56:58 -0500
In-Reply-To: <70DEDD50-4AC5-4377-B5FA-A1FBCD92EBF3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 Jan 2010 11:49:16 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> Basically what this tells me is that you can't runs these tests at all  
> if your development tree lives on an NFSv2/3 mount point.
> 

I don't think the test I have so far will do any fcntl locking, so that
one would probably work. No guarantees on any that are added later though.

It's probably best to assume that doing so would be problematic.

> > +	fi
> > +	$srcdir/../utils/statd/statd --no-notify
> 
> Is --no-notify really needed?  I guess that's just a safety net.
> 

Yeah. On the off chance that someone has monitored hosts in the db
after shutting down statd, I don't think we want to start spraying
notifications when we start the test.

> > +}
> > +
> > +# shut down statd
> > +kill_statd() {
> > +	kill `cat /var/run/rpc.statd.pid`
> > +}
> > -- 
> > 1.6.5.2
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
