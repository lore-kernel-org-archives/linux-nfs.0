From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: NFS/LSM: allow NFS to control all of its own mount options
Date: Tue, 19 Feb 2008 15:18:10 -0800 (PST)
Message-ID: <84435.4520.qm@web36603.mail.mud.yahoo.com>
References: <20080219222408.GB10656@infradead.org>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, selinux <selinux@tycho.nsa.gov>,
	linux-security-module@vger.kernel.org, steved@redhat.com,
	jlayton@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	casey@schaufler-ca.com, trond.myklebust@fys.uio.no,
	chuck.lever@oracle.com, linux-fsdevel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>,
	Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20080219222408.GB10656@infradead.org>
Sender: linux-security-module-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--- Christoph Hellwig <hch@infradead.org> wrote:

> Please don't introduce a special case for just nfs.  All filesystems
> should control their mount options, so please provide some library
> helpers for context= handling and move it into all filesystems that
> can support selinux.

Smack has options that are filesystem independent
(smackfsdef= smackfsroot= smackfsfloor= smackfshat=)
instead of the context= SELinux seems happy with.
Since there is no reason that a file system even
really needs to know what these values are it would
be completely unreasonable to teach every filesystem
about them. The information is completely controlled
and used by the LSM.

Of course, we could use something other than mount options
(vfsctl? sorry - only kidding) to set the LSM specific
information, and that might be the right approach.


Casey Schaufler
casey@schaufler-ca.com
