Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44384 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753733AbcBWOg2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Feb 2016 09:36:28 -0500
Date: Tue, 23 Feb 2016 09:36:27 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ian Kent <raven@themaw.net>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
Subject: Re: call_usermodehelper in containers
Message-ID: <20160223143627.GB31951@fieldses.org>
References: <871u2incyo.fsf@xmission.com>
 <20131118172844.GA10005@redhat.com>
 <1455149857.2903.9.camel@themaw.net>
 <8737sq4teb.fsf@x220.int.ebiederm.org>
 <56C53DE3.1070108@jp.fujitsu.com>
 <1455777387.3188.24.camel@themaw.net>
 <1455781033.2908.5.camel@themaw.net>
 <87r3g9ychc.fsf@x220.int.ebiederm.org>
 <1455858850.3356.19.camel@themaw.net>
 <1456196130.2911.10.camel@themaw.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1456196130.2911.10.camel@themaw.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 23, 2016 at 10:55:30AM +0800, Ian Kent wrote:
> You know, wrt. the mechanism Oleg suggested, I've been wondering if it's
> even necessary to capture process template information for execution.
> 
> Isn't the main issue the execution of unknown arbitrary objects getting
> access to a privileged context?
> 
> Then perhaps it is sufficient to require registration of an SHA hash (of
> some sort) for these objects by a suitably privileged process and only
> allow helper execution of valid objects.

That executable probably also depends on libraries, services, and tons
of other miscellaneous stuff in its environment.  The NFSv4 client
idmapper, for example, may be doing ldap calls.  Unless the helper is
created with incredible care, I don't think that it's enough just to
verify that you're executing the correct helper.

--b.

> 
> If that is sufficient then helper execution from within a container or
> user namespace could just use the callers environment itself.
> 
> What else do we need to be wary of, any thoughts Eric?
> 
> Ian
