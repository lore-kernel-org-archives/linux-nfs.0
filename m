From: Reid Sutherland <mofino@gmail.com>
Subject: Soft mounts
Date: Tue, 7 Dec 2004 19:32:55 -0500
Message-ID: <6a0fc8d704120716324e11dc22@mail.gmail.com>
Reply-To: reid@vianet.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbplO-0007KA-0O
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 16:33:02 -0800
Received: from rproxy.gmail.com ([64.233.170.193])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CbplJ-000061-Dn
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 16:33:01 -0800
Received: by rproxy.gmail.com with SMTP id y7so585162rne
        for <nfs@lists.sourceforge.net>; Tue, 07 Dec 2004 16:32:55 -0800 (PST)
To: nfs@lists.sourceforge.net
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

It seems soft mounts only work if the NFS server is alive and not
completely offline.  We have some hardware issues with one of our NFS
servers.  So to keep things moving we use soft mounts, but when the
server gets powered down and rebooted, soft mounts are meaningless. 
The processes are not killable, until the server comes back
(regardless of timeout)  From what I understand the 'intr' option is
also flawed in this same manner.

Am I just seeing things or is this a serious problem?

I also do not like the argument that NFS insists on keeping the
processes open even if the server is down for data integrity purposes.
 I should be able to safely turn on that insane behaviour.  I
personally need the FS error as my mail delivery method is NFS/FS
safe.

On a side note, what the hell is with NFS caching?!?  Without it I get
about 700 _KB_ per second, with it I can get 88 _MB_ per second.  I
have no tested this with 2.6, this was with 2.4.  But on the flip
side, I have to sometimes 'touch' directories to have them re-read.  I
would love to disable it.

Thanks in advance for any insight you can give me.

-reid


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
