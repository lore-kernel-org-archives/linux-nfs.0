From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: ypxfr: Can't get master address
Date: Fri, 30 Jul 2004 15:14:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407301515.00932.bernd-schubert@web.de>
References: <C9D51E2209AFD04F93E4E2E4CD6E497925924D@mail1.chesapeakebay.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "Enils Bashi" <EBashi@chesapeakebay.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqXE6-0008Q1-N1
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 06:15:10 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BqXE5-0007Vm-7B
	for nfs@lists.sourceforge.net; Fri, 30 Jul 2004 06:15:09 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <C9D51E2209AFD04F93E4E2E4CD6E497925924D@mail1.chesapeakebay.net>
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

> I am looking at my /var/log/messages on Redhat Linux 9 running ypserv
> 2.8 and here is what I see on the NIS master:
>
> Jul 30 08:00:00 <myserver> ypxfr[22647]: ypxfr: Can't get master address
> Jul 30 08:00:00 <myserver> ypserv[1505]: refused connect from
> 127.0.0.1:776 to procedure ypproc_master (linux-nis,publickey.byname;-4)
>
> Also lately our linux users have been complaining about passwords
> changes not being propagated to the nis slaves and client. I wonder
> whether these errors have anything to do with it.
>
> Any and all feedback would be greatly appreciated...
>

Well, thats a NIS problem, but this is a NFS mailing list.




-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
