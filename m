From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Direct mounts on Linux
Date: Mon, 20 Jan 2003 16:41:34 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030120214134.GE1042@questra.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ajfk-00044U-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 13:41:36 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 535F3AB71A
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 16:41:35 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <15916.14776.460148.770017@lemming.engeast.baynetworks.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Paul Smith on Mon 20/01 13:02 -0500:
> I saw a note that direct mounts are not supported on Linux; is this
> true even for autofs?  Or only for user-space stuff like am-utils?

It is true only for autofs.  Of course "mount server:/path /mount/point"
will always work :)

Word has it that the am-utils now speaks autofs to the kernel, and does
support direct mounts (among other things), so one can have the best of
both worlds (speed and features)

Now we can finally get along in a Sun environment without hacks.

autofs has its own mailing list btw


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
