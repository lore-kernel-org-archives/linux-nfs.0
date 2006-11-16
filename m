From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: "mount: File exists" when trying to mount a second krb5 volume!
Date: Wed, 15 Nov 2006 22:51:29 -0500
Message-ID: <20061116035129.GA10418@fieldses.org>
References: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Open Source <opensource3141@yahoo.com>
In-Reply-To: <20061116023117.36380.qmail@web58102.mail.re3.yahoo.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Nov 15, 2006 at 06:31:17PM -0800, Open Source wrote:
> Here's what is happening.

Thanks for your persistence!

> For the second mount to the same server, the rpc client is
> cloned and has the same path in /var/lib/nfs/rpc_pipefs/nfs
> has the first connection.  Therefore on step 3 the pipe creation
> fails in net/sunrpc/auth_gss/auth_gss.c.  This causes the
> entire mount to fail.

Argh, I could swear we've tried to fix this problem at least twice
before....

> This is a serious bug that prevents important functionality
> of nfsv3 with krb5.  I notice that kernel 2.6.19 is on release
> candidate 5.  Is there any way a surgical fix can be inserted
> into 2.6.19 before final release?

I'll take a look tommorow if someone else doesn't beat me to it, but I
doubt we'll get it done that fast.

--b.
