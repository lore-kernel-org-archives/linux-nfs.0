From: Peter Astrand <astrand@cendio.se>
Subject: Re: Improving unfsd scalability
Date: Thu, 30 Nov 2006 11:00:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0611301056440.15692@maggie.lkpg.cendio.se>
References: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; BOUNDARY="===============2034742284=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GpiiZ-00051W-Rs
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 02:00:36 -0800
Received: from mail.cendio.se ([193.12.253.69])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GpiiY-0003SS-UT
	for nfs@lists.sourceforge.net; Thu, 30 Nov 2006 02:00:37 -0800
To: Murali Bashyam <mbcoder@gmail.com>
In-Reply-To: <9c8209a10611292254s79849a6ci11fe10341017ae7e@mail.gmail.com>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--===============2034742284==
Content-Type: TEXT/Plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, 29 Nov 2006, Murali Bashyam wrote:

> Has anyone attempted to speedup concurrently handling many client NFS
> requests in unfsd? Any experience regarding multi-threading or running
> multiple processes within unfsd? Any do's and don'ts?

This is an interesting topic. I guess it depends a lot on which RPC=20
library you are using. The "normal" ONC RPC implementation, found in glib=
c=20
for example, is as far as I know not thread safe. This might be a problem=
.=20
Correct me if I'm wrong.

Regards,=20
--=20
Peter =C3=85strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Teknikringen 3
583 30 Link=C3=B6ping	Phone: +46-13-21 46 00
--===============2034742284==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============2034742284==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2034742284==--
