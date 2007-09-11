From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 2/3] Remove old logging implementation for idmapd
	and rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 17:31:03 -0400
Message-ID: <20070911213103.GC5643@fieldses.org>
References: <4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
	<1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110824t60745764l3fc63a393d51b0b9@mail.gmail.com>
	<4d569c330709110828qfaf7726we21d80d8001c92f9@mail.gmail.com>
	<20070911153742.GG13948@fieldses.org>
	<1189530078.12340.28.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911171621.GI13948@fieldses.org>
	<1189532033.12340.43.camel@moss-terrapins.epoch.ncsc.mil>
	<20070911143905.5f478095.jlayton@redhat.com>
	<1189545431.12340.54.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1189545431.12340.54.camel@moss-terrapins.epoch.ncsc.mil>
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

On Tue, Sep 11, 2007 at 05:17:11PM -0400, David P. Quigley wrote:
> I've been looking through some implementations using netlink sockets
> particularly the connector and it brings up an interesting point.
> netlink is a connectionless protocol which means it isn't "reliable".
> The connector documentation states 
> 
> "Netlink itself is not reliable protocol, that means that messages can
> be lost due to memory pressure or process' receiving queue overflowed,
> so caller is warned must be prepared. That is why struct cn_msg [main
> connector's message header] contains u32 seq and u32 ack fields." 
> 
> I don't see an indication that the connector netlink protocol implements
> some sort of reliability in the form of retransmission. I will be
> looking into this more but it seems that checks need to be made based on
> sequence and acknowledgement numbers on whether or not to retry
> messages.

I guess we'd need to understand what exactly you're trying to do.

--b.
