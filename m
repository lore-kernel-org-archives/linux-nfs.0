From: Evert <evert@poboxes.info>
Subject: Re: bad connection?
Date: Thu, 26 Oct 2006 11:36:11 +0200
Message-ID: <b5c614-okl.ln1@poboxes.info>
References: <0bg114-bqv.ln1@poboxes.info> <453E2A80.1040101@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gd1iz-00018E-3s
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 02:40:35 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gd1iy-0005o4-Bl
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 02:40:34 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1Gd1ib-0003h9-Bm
	for nfs@lists.sourceforge.net; Thu, 26 Oct 2006 11:40:09 +0200
Received: from i165182.directconnect.no ([82.148.165.182])
	by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
	id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 11:40:09 +0200
Received: from evert by i165182.directconnect.no with local (Gmexim 0.1
	(Debian)) id 1AlnuQ-0007hv-00
	for <nfs@lists.sourceforge.net>; Thu, 26 Oct 2006 11:40:09 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <453E2A80.1040101@t-online.de>
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

Egon Lehmann wrote:
> Evert wrote:
> 
>> I see a LOT of messages like the following in dmesg:
>>
>> ********************************************************
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> nfs: server 192.168.240.140 not responding, still trying
>> nfs: server 192.168.240.140 OK
>> ********************************************************
>>
>> What could the problem be? This NFS-link is very slow some times, even
>> though there's enough (640k/640k) bandwidth...
>>
>>  Evert
>>

> OK, yes I know this phenomenon, in most times is this a problem of your
> network card configuration.
> Look and your network card will have more then one IP - adresses, if
> your dhcp server your router.
> A simple action to stop this phenomenon.
> Set your ip address room on your router even the number of clients or
> define one of your computer systems as the dhcp server with out
> automaticaly assignment of ip adresses.
> regards
>    Egon Lehmann

I am not sure whether I understand you correctly...
How does a  DHCP-server influence NFS?

In my case both the server (192.168.240.140) & the client
(192.168.10.25) have static IP addresses...

Regards,
  Evert


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
