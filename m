From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfs client monitoring?
Date: Thu, 29 Jul 2004 20:25:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407292025.55361.bernd-schubert@web.de>
References: <41092832.3030400@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqFbR-0003eq-Gb
	for nfs@lists.sourceforge.net; Thu, 29 Jul 2004 11:26:05 -0700
Received: from smtp07.web.de ([217.72.192.225])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BqFbQ-0001ND-W4
	for nfs@lists.sourceforge.net; Thu, 29 Jul 2004 11:26:05 -0700
Received: from [80.140.5.56] (helo=bathl.lan.fli4l)
	by smtp07.web.de with asmtp (TLSv1:RC4-MD5:128)
	(WEB.DE 4.101 #44)
	id 1BqFbJ-000448-00
	for nfs@lists.sourceforge.net; Thu, 29 Jul 2004 20:25:57 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <41092832.3030400@psu.edu>
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

On Thursday 29 July 2004 18:39, Jason Holmes wrote:
> Hi,
>
> Is there a command that can show the demands being placed on the nfs
> server by each individual client?  I run into the situation from time to
> time where a random user will do something that puts an extreme load on
> the fileserver and having such a command would help greatly in trying to
> figure out the source of the load.
>

We usually use iftop for that purpose.

Cheers,
	Bernd


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
