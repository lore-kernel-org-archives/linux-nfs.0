From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3+Krb5 and mountd
Date: Mon, 30 Aug 2004 13:17:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830171734.GC1555@fieldses.org>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org> <20040830020132.GA28919@fieldses.org> <20040830154541.GA3671@nasse> <1093884302.8729.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Per Olofsson <pelle@dsv.su.se>, Paul Jakma <paul@clubi.ie>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1pmx-0003xd-Iv
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:17:51 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1pmt-0000od-BS
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 10:17:48 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1093884302.8729.21.camel@lade.trondhjem.org>
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

On Mon, Aug 30, 2004 at 12:45:02PM -0400, Trond Myklebust wrote:
> På må , 30/08/2004 klokka 11:45, skreiv Per Olofsson:
> 
> > OK, I understand. I don't really need authenticated mount requests
> > though, I only need authenticated file system accesses. In other
> > words, I don't care who mounts the file system as long as they can't
> > impersonate a user without a valid ticket. Is this easier to
> > implement? Does it have any other security implications?
> 
> This is already implemented...
> 
> The RPCSEC_GSS implementation that is in linux-2.6.x already follows the
> guidelines in RFC2623 when you mount an NFSv2 or v3 partition.

I believe (can't find the right language now) that RFC2623 says it's OK
for the server to allow the client to do MOUNT requests and a few
filesystem requests (sufficient for statfs) without rpcsec_gss, even on
rpcsec_gss exports.  Our server and mountd currently do *not* do that.

Since they also don't support rpcsec_gss, that means we're in the
unfortunate position that the only practical way to mount an nfsv2/3
filesystem with krb5 right now is to first make sure the filesystem is
also exported to the client (read-only should suffice) via auth_sys.

I think that adding rpcsec_gss support to the userland utilities, and
making it easy for people to distribute keytabs to their clients, is the
better long-term solution than enabling RFC2623's workarounds.  But
maybe too many clients already expect to be able to mount with auth_sys
only.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
