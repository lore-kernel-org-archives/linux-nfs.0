From: "Jocky Wilson" <jocky_wilson@hotmail.com>
Subject: Re: rsize, wsize > 32Kb : how?
Date: Fri, 10 Dec 2004 00:02:28 +0000
Message-ID: <BAY21-F9182AE183E85A116E03F1E4A80@phx.gbl>
References: <1102636343.3784.27.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcYGO-00042H-Sk
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 16:04:00 -0800
Received: from bay21-f9.bay21.hotmail.com ([65.54.233.98] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CcYGO-0001ye-KE
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 16:04:00 -0800
In-Reply-To: <1102636343.3784.27.camel@tesuji.nac.uci.edu>
To: strombrg@dcs.nac.uci.edu
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

No, my LAN is fast ethernet and the NAS and PCs are in 100 full duplex. My 
streaming client even has a 10mb half duplex nic. I noticed a consistent 
write performance increase when changing wsize from 8192->16384->32768

I did increase rmem and wmem values from 32767 (yes) to 65536, which doesn't 
seem to make a difference.

JockyW

>From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
>Date: Thu, 09 Dec 2004 15:52:23 -0800
>
>
>Is it safe to assume you've enabled jumbo frames?
>
>Without jumbo frames, a huge packet size isn't necessarily going to make
>things faster...
>




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
