From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3+Krb5 and mountd
Date: Sun, 29 Aug 2004 22:01:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040830020132.GA28919@fieldses.org>
References: <20040824184138.GB3251@nasse> <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Per Olofsson <pelle@dsv.su.se>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1bUU-0001VJ-QP
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 19:01:50 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1C1bUS-0000aK-Tn
	for nfs@lists.sourceforge.net; Sun, 29 Aug 2004 19:01:50 -0700
To: Paul Jakma <paul@clubi.ie>
In-Reply-To: <Pine.LNX.4.61.0408300238530.2441@fogarty.jakma.org>
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

On Mon, Aug 30, 2004 at 02:41:28AM +0100, Paul Jakma wrote:
> On Tue, 24 Aug 2004, Per Olofsson wrote:
> 
> >And it works! I can tell that it uses Kerberos because I can write 
> >to the mounted fs if I have a ticket, but not without. The drawback 
> >is that I am now allowing AUTH_SYS mounting as well, which I want 
> >to avoid. Is this a bug in mountd? Is it difficult to fix?
> 
> It's a bug in mountd yes. J Bruce Fields had actually sent me a wee 
> patch to try fix it for me to test a good while ago, but I havnt 
> gotten back to looking at NFSv3+GSS since then:

This doesn't fix the problem Per Olofsson describes, which is that
unless you use nfsv4, there's no way to export to krb5 without also
exporting vi auth_sys.

Since mountd itself doesn't currently have rpcsec_gss support (and, on
the client side, neither does mount), MOUNT requests are going to use
auth_sys.  So mountd is going to decide whether to respond based on
their IP address.

It'd seem that the right solution is to add rpcsec_gss support to mount
and mountd, which shouldn't be a big project, so if you export only to
krb5 then you also answer krb5-protected mount requests.  I don't know
whether other clients will like that, though.

--Bruce Fields


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
