From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: svc_process and nfsd_proc_read not taking checksum into
	account when calling svc_reserve
Date: Fri, 20 Apr 2007 14:38:38 -0400
Message-ID: <20070420183838.GJ19285@fieldses.org>
References: <4628D19F.5080805@redhat.com> <20070420174748.GG19285@fieldses.org>
	<4d569c330704201057l1ba2a131r39df22db6e917fb3@mail.gmail.com>
	<20070420181144.GI19285@fieldses.org> <46290789.7080908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hey0H-0000pF-Ga
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 11:38:42 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hey0H-0003ER-Bn
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 11:38:43 -0700
In-Reply-To: <46290789.7080908@redhat.com>
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

On Fri, Apr 20, 2007 at 02:33:45PM -0400, Jeff Layton wrote:
> Thanks for the info. I'll shoot for just having the wrapper add a 
> constant value to it for now (though I'll at least get the auth flavor 
> and set that value to 0 for auth_null and auth_unix).
> 
> I tested krb5p and it seems to be off by 52 bytes, but I was using 
> des-cbc-crc:normal. Got a suggestion of what kerberos enc type I should 
> use to try to maximize the length?

That's all we've got in mainline right now--the others are only in
experimental code.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
