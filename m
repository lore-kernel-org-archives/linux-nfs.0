From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error (try #2)
Date: Fri, 18 Dec 2009 15:56:52 -0500
Message-ID: <1261169812.3420.68.camel@localhost>
References: <1261153637-6209-1-git-send-email-jlayton@redhat.com>
	<1261163139.3420.17.camel@localhost>
	<20091218151345.5e86149d@tlielax.poochiereds.net>
	<1261167866.3420.40.camel@localhost>
	<20091218153841.1fbd5357@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091218153841.1fbd5357@tlielax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 15:38 -0500, Jeff Layton wrote:

> Well, I'd like to think that we'd always get the lower layers right, but
> I know better :). We probably ought to code defensively here and account
> for the possibility that this function could return a different error
> due to an inadvertent change in a lower function.
> 
> If the "bad" error is transient then -EAGAIN would probably just paper
> over it. If it's not transient then the mount would hang. -EACCES is a
> nice hard error, but could be confused with a "real" -EACCES. We could
> BUG() in that case if we're sure it'd be a real bug...


switch (err) {
case -EACCES:
gss_msg->msg.errno = -EACCES;
break;
case -EFAULT:
case -ENOMEM:
case -EINVAL:
case -ENOSYS:
gss_msg->msg.errno = -EAGAIN;
break;
default:
BUG();
}

Yup. That looks good to me... ..and with the fixes to
gss_import_sec_context_kerberos and gss_import_sec_context, it will
actually be correct too.

BTW: get_key() returns EINVAL on error, so that does indeed need to be
supported in the above list.

Trond
