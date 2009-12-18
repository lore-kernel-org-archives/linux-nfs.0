From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
	return error
Date: Fri, 18 Dec 2009 11:25:24 -0500
Message-ID: <20091218112524.499ccaa9@tlielax.poochiereds.net>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
	<20091218093912.1c426ad6@tlielax.poochiereds.net>
	<1261147672.3229.14.camel@localhost>
	<20091218102550.6a48c900@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20091218102550.6a48c900@tlielax.poochiereds.net>
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

On Fri, 18 Dec 2009 10:25:50 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> Sure. I see another problem in this area too. gss_import_sec_context
> can return GSS_S_FAILURE which is unsigned and positive when cast to a
> signed value. gss_import_sec_context checks for a negative return from
> that function though. Should it be checking for non-zero instead?

Oops, sorry. I meant to say "gss_fill_context checks for a negative
return".

-- 
Jeff Layton <jlayton@redhat.com>
