From: Razvan Gavril <razvan.g@plutohome.com>
Subject: Re: Nfs problem on target
Date: Mon, 24 Jul 2006 10:42:33 +0300
Message-ID: <44C479E9.307@plutohome.com>
References: <003101c6aee9$64f41a90$802cc70a@dlh.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G4v5O-00018m-4p
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 00:42:42 -0700
Received: from k2smtpout02-01.prod.mesa1.secureserver.net ([64.202.189.90])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1G4v5N-0001RD-6m
	for nfs@lists.sourceforge.net; Mon, 24 Jul 2006 00:42:42 -0700
To: Manish RATHI <manish.rathi@st.com>
In-Reply-To: <003101c6aee9$64f41a90$802cc70a@dlh.st.com>
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

Manish RATHI wrote:
> Hi,
> When I use NFS on 2.4.20 kernel running on my target board, there is no problem?
> When I migrate to 2.6.16 and enabled nfs then 
> Whenever I execute an application over nfs which access NFS for
> Reading files, I get frequent prints 
> "nfs : server 10.199.3.88 not responding, still trying"
> " nfs : server 10.199.3.88 OK"
>
> On FAQ it's written this can be because of 
> Network congestion 
> Overloaded server 
> Packets (input or output) dropped by a bad NIC or driver.... 
>
> But this problem is not with 2.4 kernel. 
>
> Thanks
> Regards
> Manish
>
>   
I have similar problems when using 2.6.16 on the server :( and using a 
single client who is doing a cp.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
