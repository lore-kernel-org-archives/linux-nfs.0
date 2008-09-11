From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Thu, 11 Sep 2008 03:27:29 -0700
Message-ID: <m1r67rgepa.fsf@frodo.ebiederm.org>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com>
	<m18wu1nyon.fsf@frodo.ebiederm.org>
	<20080909152952.GA21207@us.ibm.com>
	<DE845309-1684-472A-8269-78AB3A2823A9@oracle.com>
	<m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com>
	<76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com>
	<m1ej3rixbx.fsf@frodo.ebiederm.org> <48C8DEA0.9080905@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60583 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198AbYIKKfH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2008 06:35:07 -0400
In-Reply-To: <48C8DEA0.9080905-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Thu, 11 Sep 2008 11:02:24 +0200")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

>> The conservative play is to always force use of the initial namespace
>> and to deny creation of mounts that would use different namespaces.  In part
>> because the initial version of the namespace always exists.  Which means
>> as relates to Cedrics initial patch we would still need to know which
>> mounts should cause us to use a different uts namespace so we can deny
>> them.
>
> I will send the initial patch which forces use of the initial namespace because
> it does fix a real oops. 
>
> Then, I should be able to find some time to work on improving the uts namespace
> checks when NFS mounts are done.

Thanks.
Eric
