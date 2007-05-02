From: Omri Schwarz <ocschwar@MIT.EDU>
Subject: Re: Linux & RPC_GSS with NFS version 3
Date: Wed, 2 May 2007 15:51:02 -0400 (EDT)
Message-ID: <Pine.GSO.4.64L.0705021546190.18104@biohazard-cafe.mit.edu>
References: <Pine.GSO.4.64L.0705021534300.16975@biohazard-cafe.mit.edu>
	<20070502194310.GG23284@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjKr6-0003RH-QD
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:51:16 -0700
Received: from biscayne-one-station.mit.edu ([18.7.7.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjKr8-0007RE-7b
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 12:51:19 -0700
In-Reply-To: <20070502194310.GG23284@fieldses.org>
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



On Wed, 2 May 2007, J. Bruce Fields wrote:

> On Wed, May 02, 2007 at 03:40:16PM -0400, Omri Schwarz wrote:
>> Hi, all. I am trying to get Fedora Coure 6 machines to talk
>> NFS 3 to each other with sec=krb5, and for the moment,
>> though I have gotten them to talk over other GSSAPI-enabled
>> services (ssh, imap, ftp, smtp and NFS 4), NFS 3 fails.
>> The server says
>> """
>> mountd: MNT3(/export) called
>> mountd: mount request from unknown host 18.75.0.50 for /export (/export)
>> """.
>>
>> Going deeply enough I can see that mountd (1.0.10-7.fc6)
>> continues to check IP addresses against the string "gss/krb5" instead of
>> doing the right thing and having a chat with svcgssd.
>> I'll be gratefull for any help in getting mountd to DTRT here.
>
> It's a known problem; it'll only work if you also export to the ip
> address (read-only if you want, though note that may cause problems with
> locking, since nlm also uses auth_unix).

Yup, that fixed the problem. Thanks!

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
