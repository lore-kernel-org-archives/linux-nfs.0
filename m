From: oudoubah@altern.org
Subject: Re: nfs over ssh : invalid protocol
Date: Tue, 9 Jan 2007 10:52:56 +0100 (CET)
Message-ID: <59048.193.178.136.53.1168336376.squirrel@altern.org>
References: <36900.193.178.136.53.1168256160.squirrel@altern.org>
	<87ac0seob4.fsf@freeze.oslo.dnmi.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4CgI-00082S-It
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 00:50:06 -0800
Received: from altern.org ([80.67.174.57] helo=filer2.altern.org ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H4CgI-0005ME-CH
	for nfs@lists.sourceforge.net; Tue, 09 Jan 2007 00:50:08 -0800
In-Reply-To: <87ac0seob4.fsf@freeze.oslo.dnmi.no>
To: "Adrian Phillips" <a.phillips@met.no>
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

>     Oudoubah> There is a firewall between the two servers, and only
>     Oudoubah> the port 22 and 111 are open.
>
> Try openvpn through one of these ports instead.

One of the server is critical, so i'm not allowed to install anything on
it. But thanks for the advice.

> Does forcing the use of a protocol version (for instance nfsvers=3) help ?

It doesn't help

> Is it really possible to use statd/lockd over SSH? Otherwise, I would try
mounting with "nolock".

I tried with this option, but the error still occurs.


> If that fails, a Wireshark trace should give you a hint. Another hint is
> that some versions of Fedora and RHEL have a broken mount command (unless
> the updates are installed), see
>https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=140016.

The two servers are Red Hat 3.4.3-9.EL4. I'll search if i'm concerned by
the bug.
How can i do a wireshark trace?

Oudoubah


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
