From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Full IPv6 client and server support (kernel and user commands)
Date: Wed, 24 Sep 2008 12:51:08 -0400
Message-ID: <20080924165108.GC5772@fieldses.org>
References: <48D39CDE.1040600@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	nfsv4 <nfsv4@linux-nfs.org>
To: Le Rouzic <aime.le-rouzic@bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <48D39CDE.1040600@bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 19, 2008 at 02:36:46PM +0200, Le Rouzic wrote:
> I have just posted at http://nfsv4.bullopensource.org/ a full IPV6 
> client and server NFSV4 support
> based on linux-2.6.27-rc3 and nfs-utils.1.1.2.
> It is experimental and not fully tested but it allows to have a IPV6 
> NFSV4 linux configuration to
> play with.
> 
> Let me know if any issues to get this delivery and to run it.

I took a quick look at the server patch available from the URL above.

There are more #if's than necessary--for example, maybe you could define
a constant once in a header to choose the correct address family rather
than putting #if's around all the svc_create() calls?

It'd be worth running this by Chuck, as he's been doing a good job of
that kind of thing.

Could you mail future versions of any patches to the mailing list in the
usual format, rather than providing a URL?  That'd save us a little
time.

--b.
