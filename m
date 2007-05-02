From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux & RPC_GSS with NFS version 3
Date: Wed, 2 May 2007 15:43:10 -0400
Message-ID: <20070502194310.GG23284@fieldses.org>
References: <Pine.GSO.4.64L.0705021534300.16975@biohazard-cafe.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Omri Schwarz <ocschwar@MIT.EDU>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjKjH-0002t6-Vf
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:43:12 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjKjJ-00008x-5A
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:43:14 -0700
In-Reply-To: <Pine.GSO.4.64L.0705021534300.16975@biohazard-cafe.mit.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, May 02, 2007 at 03:40:16PM -0400, Omri Schwarz wrote:
> Hi, all. I am trying to get Fedora Coure 6 machines to talk
> NFS 3 to each other with sec=krb5, and for the moment,
> though I have gotten them to talk over other GSSAPI-enabled
> services (ssh, imap, ftp, smtp and NFS 4), NFS 3 fails.
> The server says
> """
> mountd: MNT3(/export) called
> mountd: mount request from unknown host 18.75.0.50 for /export (/export) 
> """.
> 
> Going deeply enough I can see that mountd (1.0.10-7.fc6)
> continues to check IP addresses against the string "gss/krb5" instead of
> doing the right thing and having a chat with svcgssd.
> I'll be gratefull for any help in getting mountd to DTRT here.

It's a known problem; it'll only work if you also export to the ip
address (read-only if you want, though note that may cause problems with
locking, since nlm also uses auth_unix).

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
