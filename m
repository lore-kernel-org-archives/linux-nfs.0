From: "Ogden, Aaron A." <aogden@unocal.com>
Subject: RE: ~800 mountpoint limitation
Date: Fri, 17 Oct 2003 12:37:28 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6AB920CC10586340BE1674976E0A991D59562D@slexch2.sugarland.unocal.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAYZr-0006zP-00
	for <nfs@lists.sourceforge.net>; Fri, 17 Oct 2003 10:39:52 -0700
Received: from unogate.unocal.com ([192.94.3.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAYZk-0005lx-IW
	for nfs@lists.sourceforge.net; Fri, 17 Oct 2003 10:39:44 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
        "Lever, Charles" <Charles.Lever@netapp.com>
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


According to MW and EW (Sun and HP, respectively) this is the way it's
done on Solaris and HPUX so I think it's safe to say it's a proven
concept.  You go Trond!!  :-D

> I'm not really sure that I buy the argument about the server disks
> getting busy. That will tend to hit you whether or not you are sharing
> RPC slots, since it also ties up server resources.
>=20
> The main point with putting all the transport to a given server on one
> socket is that the UDP/TCP congestion control algorithms can then
> function efficiently. Instead of competing against other packets
> originating from itself, the client only has to deal with competition
> from other clients.
>=20
> Cheers,
>   Trond


-------------------------------------------------------
This SF.net email sponsored by: Enterprise Linux Forum Conference & Expo
The Event For Linux Datacenter Solutions & Strategies in The Enterprise 
Linux in the Boardroom; in the Front Office; & in the Server Room 
http://www.enterpriselinuxforum.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
