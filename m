From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.21 strange optimization in svcauth_unix.c
Date: Fri, 27 Apr 2007 19:19:41 +0200
Message-ID: <20070427171941.GA27920@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhU6j-0003F2-Su
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:19:46 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhU6l-0005LF-6n
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:19:48 -0700
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

While reading the 2.6.21 version of net/sunrpc/svcauth_unix.c it looks
to me that it tries to cache the AUTH_UNIX/AUTH_SYS group list on uid
basis and thus deliberately ignore the group ids supplied by the NFS
client. Fragment of svcauth_unix_accept():

	cred->cr_uid = svc_getnl(argv);		/* uid */
	cred->cr_gid = svc_getnl(argv);		/* gid */
	slen = svc_getnl(argv);			/* gids length */
	if (slen > 16 || (len -= (slen + 2)*4) < 0)
		goto badcred;
=>	if (unix_gid_find(cred->cr_uid, &cred->cr_group_info, rqstp)
	    == -EAGAIN)
		return SVC_DROP;
=>	if (cred->cr_group_info == NULL) {
		cred->cr_group_info = groups_alloc(slen);
		if (cred->cr_group_info == NULL)
			return SVC_DROP;
		for (i = 0; i < slen; i++)
			GROUP_AT(cred->cr_group_info, i) = svc_getnl(argv);
=>	} else {
=>		for (i = 0; i < slen ; i++)
=>			svc_getnl(argv);
=>	}

I guess this caching will break the linux NFS client patch for bypassing
the 16 groups limits maintained by me (http://www.frankvm.com/nfs-ngroups/ )
because in order to bypass the group limitation the group list is
determined dynamically at the NFS client.

Of course I can just disable the above optimization in my own patch but
I wonder what its real purpose is. I don't see a big win so is it an
optimization or is there another reason?

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
