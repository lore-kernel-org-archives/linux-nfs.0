From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 14:04:02 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830180402.GE1555@fieldses.org>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org> <20040830020132.GA28919@fieldses.org> <20040830154541.GA3671@nasse> <1093884302.8729.21.camel@lade.trondhjem.org> <20040830171734.GC1555@fieldses.org> <1093887933.8729.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Per Olofsson <pelle@dsv.su.se>, Paul Jakma <paul@clubi.ie>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1qVo-0004Z2-R2
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 11:04:12 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1qVm-0004Nw-1G
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 11:04:12 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093887933.8729.35.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Aug 30, 2004 at 01:45:33PM -0400, Trond Myklebust wrote:
> På må , 30/08/2004 klokka 13:17, skreiv J. Bruce Fields:
> 
> > I believe (can't find the right language now) that RFC2623 says it's OK
> > for the server to allow the client to do MOUNT requests and a few
> > filesystem requests (sufficient for statfs) without rpcsec_gss, even on
> > rpcsec_gss exports.  Our server and mountd currently do *not* do that.
> 
> Right. The RFC says that the NFS server should allow AUTH_SYS
> authenticated NFSPROC3_FSINFO (NFSv3) and NFSPROC_GETATTR+NFSPROC_STATFS
> (NFSv2) calls on the root filehandle (and *only* on the root
> filehandle).

And also, though it seems to be just implicit, it expects you to be able
to do MOUNT.

Since we specify the rpcsec_gss security flavor as the client in
/etc/exports, in the place of the ip address/network/whatever, this
means in practice we'd need to allow MOUNT from any ip address for a
filesystem that's exported to rpcsec_gss.  Which I suppose is OK, though
I don't understand why clients really want to do that.

> mountd should always support AUTH_SYS, so no changes required there
> (apart from the need to add the supported RPCSEC_GSS pseudoflavours to
> the "auth_flavors" list).
> As far as I know, nobody (not even Sun) has set up NLM to work with
> RPCSEC_GSS either.

Well, I suppose unauthenticated locks are a DOS at worse.  But the
lookup of the initial filehandle seems more security-critical to me.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
