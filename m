From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 3 bugs with UDP mounts
Date: Mon, 22 Apr 2002 14:22:51 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0204221522510P.01167@stinkpad060501>
References: <OF1E841CCB.33C98FFC-ON88256BA3.005D4EE6@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from laswell.sfo.collab.net ([64.125.134.138])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zmDX-0003dS-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 15:23:27 -0700
To: "Bruce Allan" <bruce.allan@us.ibm.com>
In-Reply-To: <OF1E841CCB.33C98FFC-ON88256BA3.005D4EE6@boulder.ibm.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Monday 22 April 2002 10:00 am, Bruce Allan wrote:
> I also witnessed the same problem (problem #3 below) at the Connectathon
> event this year with NFSv3 on both TCP and UDP.  Trond was there and he
> verified this was a bug in NetApp's ONTAP 6.1.1 having to do with, IIRC,
> how they handle byte swapping against little-endian clients.  This bug was
> also discovered at the 2001 Connectathon event.  NetApp fixed this in a
> later release of ONTAP (I think they said it was fixed in 6.1.2 but don't
> quote me on that).

Thanks for the info. We're running 6.1.2R1, so I would guess they've not 
fixed it yet. Perhaps in 6.1.3. I wonder, is the problem basically cosmetic 
or does it manifest itself in other places as well?


andrew

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
