Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:46835 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753899AbcBXAzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Feb 2016 19:55:25 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 794812128A
	for <linux-nfs@vger.kernel.org>; Tue, 23 Feb 2016 19:55:24 -0500 (EST)
Message-ID: <1456275316.2933.14.camel@themaw.net>
Subject: Re: call_usermodehelper in containers
From: Ian Kent <raven@themaw.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Wed, 24 Feb 2016 08:55:16 +0800
In-Reply-To: <20160223143627.GB31951@fieldses.org>
References: <871u2incyo.fsf@xmission.com>
	 <20131118172844.GA10005@redhat.com> <1455149857.2903.9.camel@themaw.net>
	 <8737sq4teb.fsf@x220.int.ebiederm.org> <56C53DE3.1070108@jp.fujitsu.com>
	 <1455777387.3188.24.camel@themaw.net> <1455781033.2908.5.camel@themaw.net>
	 <87r3g9ychc.fsf@x220.int.ebiederm.org>
	 <1455858850.3356.19.camel@themaw.net> <1456196130.2911.10.camel@themaw.net>
	 <20160223143627.GB31951@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-02-23 at 09:36 -0500, J. Bruce Fields wrote:
> On Tue, Feb 23, 2016 at 10:55:30AM +0800, Ian Kent wrote:
> > You know, wrt. the mechanism Oleg suggested, I've been wondering if
> > it's
> > even necessary to capture process template information for
> > execution.
> > 
> > Isn't the main issue the execution of unknown arbitrary objects
> > getting
> > access to a privileged context?
> > 
> > Then perhaps it is sufficient to require registration of an SHA hash
> > (of
> > some sort) for these objects by a suitably privileged process and
> > only
> > allow helper execution of valid objects.
> 
> That executable probably also depends on libraries, services, and tons
> of other miscellaneous stuff in its environment.  The NFSv4 client
> idmapper, for example, may be doing ldap calls.  Unless the helper is
> created with incredible care, I don't think that it's enough just to
> verify that you're executing the correct helper.

Yeah, I was thinking the logistics of keeping something like this up to
date would be hard but calculating this for every call would be too much
overhead I think.

> 
> --b.
> 
> > 
> > If that is sufficient then helper execution from within a container
> > or
> > user namespace could just use the callers environment itself.
> > 
> > What else do we need to be wary of, any thoughts Eric?
> > 
> > Ian
