From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Wed, 24 Nov 2004 00:26:36 +0100
Message-ID: <20041123232636.GE19342@vestdata.no>
References: <41A39D57.8060902@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWk3d-0007Hm-8O
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 15:26:49 -0800
Received: from [217.149.127.10] (helo=stine.vestdata.no)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWk3c-0000rg-02
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 15:26:49 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41A39D57.8060902@RedHat.com>
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

On Tue, Nov 23, 2004 at 03:28:07PM -0500, Steve Dickson wrote:
> Here is a patch that make sure the correct hostname is used
> in the SM_NOTIFY message what is sent from a rebooted server
> that has multiple network interfaces.
>=20
> Using the network part of the destination address, the correct network
> interface is found. Then a gethostbyaddr() on that interface is done,
> which yields the correct hostname that should be sent in the notify
> message....
>=20
> Comments?

It has been a while since I looked at this code, but:
1. What happens when you run statd with the "-n" option?
   Does this patch override the name the user gave?

2. Does this really find the correct hostname?
   If I'm not mistaken, the nfs client needs to get a SM_NOTIFY message
   with the hostname that it actually mounted from, right?
   This may or may not match the hostname that the server find when
   running gethostbyaddr on the interface's IP, so one can easily find
   scenarios where this patch will cause statd to stop working.

   Now, there new behavious may actually be better, but I'm not sure
   it's acceptable to change it anyway?

   Could an alternative be to send out SM_NOTIFY messages for multiple
   hostnames? Both the one from gethostname() and the ones found by
   reverse lookup from the interfaces? Then I guess the meaning of the
   "-n" option could be changed to _add_ a hostname to the list of
   names to broadcast for?=20



--=20
Ragnar Kj=F8rstad
Software Engineer
Scali - http://www.scali.com
High Performance Clustering


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
