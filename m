From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Authenticated NFS mounts
Date: Tue, 18 Oct 2005 09:25:36 -0400
Message-ID: <20051018132536.GB25424@fieldses.org>
References: <dj2kkn$4hr$1@benzin.geggus.net> <200510181313.09401.vincent.roqueta@ext.bull.net> <dj2ma2$52v$1@benzin.geggus.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERrTJ-0001Vo-A0
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 06:25:41 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERrTH-0006SH-Vd
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 06:25:41 -0700
To: Sven Geggus <sven-im-usenet@gegg.us>
In-Reply-To: <dj2ma2$52v$1@benzin.geggus.net>
Sender: nfs-admin@lists.sourceforge.net
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

On Tue, Oct 18, 2005 at 11:29:06AM +0000, Sven Geggus wrote:
> Vincent Roqueta <vincent.roqueta@ext.bull.net> wrote:
> 
> >> Is ist possible to use RPCSEC GSSAPI in conjunction with NFSv3 on Linux
> >> Clients and Servers?
> > Yes, that is possible.
> 
> Any kind of mini HOWTO on this? Which Versions of mount, nfs-utils etc would
> I need?

If you have versions of those things that support NFSv4, then they
almost certainly also has v3/rpcsec_gss support.

> Protection against mounts from untrusted machines which are not
> authenticated is all I need to provide at the Moment.
> 
> NFSv4 seems to be a better design, but stability is more important for my
> application.

Could you give any more details on the "lockups" you were seeing?  Which
kernel were you using (client and server), what exactly happened, what
workload caused it, etc.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
