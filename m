From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [RFC][PATCH] sunrpc: fix oops in rpc_create() when the mount
 namespace is unshared
Date: Thu, 11 Sep 2008 11:02:24 +0200
Message-ID: <48C8DEA0.9080905@fr.ibm.com>
References: <48C52B29.4020204@fr.ibm.com> <20080909124311.GA10053@us.ibm.com> <m18wu1nyon.fsf@frodo.ebiederm.org> <20080909152952.GA21207@us.ibm.com> <DE845309-1684-472A-8269-78AB3A2823A9@oracle.com> <m1fxo9mba5.fsf@frodo.ebiederm.org> <48C791F9.8090606@fr.ibm.com> <76bd70e30809100812r4a7fa71crfc7196350e3ed1cf@mail.gmail.com> <m1ej3rixbx.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chucklever@gmail.com, "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	linux-nfs@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754675AbYIKJDF@vger.kernel.org>
In-Reply-To: <m1ej3rixbx.fsf@frodo.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> The conservative play is to always force use of the initial namespace
> and to deny creation of mounts that would use different namespaces.  In part
> because the initial version of the namespace always exists.  Which means
> as relates to Cedrics initial patch we would still need to know which
> mounts should cause us to use a different uts namespace so we can deny
> them.

I will send the initial patch which forces use of the initial namespace because
it does fix a real oops. 

Then, I should be able to find some time to work on improving the uts namespace
checks when NFS mounts are done.

Thanks !

C.
