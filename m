From: Kasparek Tomas <kasparek@fit.vutbr.cz>
Subject: Re: NFS corruption in 2.6.18.2?
Date: Wed, 15 Nov 2006 18:29:47 +0100
Message-ID: <20061115172947.GM10830@fit.vutbr.cz>
References: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GkOuz-0001oY-Ph
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:51:25 -0800
Received: from kazi.fit.vutbr.cz ([147.229.8.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GkOuy-0007Rr-FX
	for nfs@lists.sourceforge.net; Wed, 15 Nov 2006 09:51:27 -0800
To: Fredrik Lindgren <fli@swip.net>
In-Reply-To: <50e235a50d0f2b4fb34eed1c840565e3@swip.net>
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

On Tue, Nov 14, 2006 at 07:09:17PM +0100, Fredrik Lindgren wrote:
> Hello
> 
> We're running a mail system with Linux machines being served by two
> NetApps. (Debian stable, our "own" kernel off kernel.org)
> 
> At present we're running 2.6.13 kernels, we had some corruption issues
> before that was fixed in 2.6.13. However when we tried to upgrade
> to 2.6.18.2 the we see corruption again.
> 
> pre 2.6.13 the problem seemed to be that the file size was being
> cached, which meant that sometimes there were blocks of NULL
> characters in the files.
> 
> With 2.6.18.2 we see blocks of NULL chars in the data again, this time
> it's sometimes in the middle of a message. pre 2.6.13 that didn't
> happen,
> then there were just big blocks of NULL chars between two messages. 
> The only consistent thing is that it only occurs when the 1 machine
> running 2.6.18.2 (out of 5) has delivered a message to the spool-file.
> 
> I don't know if it's relevant, but when checking the NFS stats I see
> the 2.6.18.2 machine doing almost precisely half the amount of "GetAttr"
> calls compared to the 2.6.13 machines.
> 
> Is this something anyone else has seen?
> 
> Also on a side note, the statistics still seem to be using signed
> values, so we're seeing negative numbers on some stats after some
> uptime. This is true for both using "nfsstat" and "cat
> /proc/net/rpc/nfs.

I have seen this behaviour with kernel 2.6.18 and above up to 19-rc4.
Reported this, but no response.

http://lkml.org/lkml/2006/9/28/89

--   

  Tomas Kasparek, PhD student  E-mail: kasparek@fit.vutbr.cz
  CVT FIT VUT Brno, BI/140a    Web:    http://www.fit.vutbr.cz/~kasparek
  Bozetechova 2, 612 66        Fax:    +420 54114-1270
  Brno, Czech Republic         Phone:  +420 54114-1220

  ICQ: 293092805  jabber: tomas.kasparek@jabber.cz
  GPG: 2F1E 1AAF FD3B CFA3 1537  63BD DCBE 18FF A035 53BC


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
