From: "Bruce Allan" <bruce.allan@us.ibm.com>
Subject: Re: 3 bugs with UDP mounts
Date: Mon, 22 Apr 2002 15:32:45 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF17118CDD.39553354-ON88256BA3.007B1A86@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zmMj-0004me-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 15:32:57 -0700
To: Andrew Ryan <andrewr@nam-shub.com>
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


FYI, NetApp had another server at Connectathon2002 running ONTAP 6.2 X37
which did not exhibit this problem.

I can't speak of the extent of the bug as the Connectathon cthon02 test
suite is the extent of my exposure to NetApp servers.

---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187



                                                                                                                                   
                      Andrew Ryan                                                                                                  
                      <andrewr@nam-shub        To:       Bruce Allan/Beaverton/IBM@IBMUS                                           
                      .com>                    cc:       nfs@lists.sourceforge.net                                                 
                                               Subject:  Re: [NFS] 3 bugs with UDP mounts                                          
                      04/22/2002 03:22                                                                                             
                      PM                                                                                                           
                                                                                                                                   
                                                                                                                                   




On Monday 22 April 2002 10:00 am, Bruce Allan wrote:
> I also witnessed the same problem (problem #3 below) at the Connectathon
> event this year with NFSv3 on both TCP and UDP.  Trond was there and he
> verified this was a bug in NetApp's ONTAP 6.1.1 having to do with, IIRC,
> how they handle byte swapping against little-endian clients.  This bug
was
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
