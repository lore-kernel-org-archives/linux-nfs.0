From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 2/3] Remove old logging implementation for idmapd
	and rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 17:30:38 -0400
Message-ID: <20070911213038.GB5643@fieldses.org>
References: <1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
	<1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911171621.GI13948@fieldses.org>
	<1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911143905.5f478095.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070911143905.5f478095.jlayton@redhat.com>
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

On Tue, Sep 11, 2007 at 02:39:05PM -0400, Jeff Layton wrote:
> There's a somewhat related issue to this as well. I've started looking
> over what it would take to add kerberos support to CIFS. It would be
> *really* nice to be able to use the same gssd that NFS is using and
> just massage that data for CIFS.
> 
> Doing this with the current rpc_pipefs based daemon is going to be
> problematic though. I don't think we want CIFS to be dependent on RPC,
> and ripping that code out of the sunrpc module would be a pain.

Actually, Daniel Phillips did that a while ago, and I updated it once.
I don't think it'd been tested, but it's hidden away in my git repo, at
refs/attic/rpc_pipefs_library;

	git remote add bfields git://linux-nfs.org/~bfields/linux.git
	git fetch bfields refs/attic/rpc_pipefs_library:foo
	git checkout foo

should get it.

The rpc_pipefs code really shouldn't need to depend on the rest of the
rpc code.

--b.
