From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: AW: URGENT: Problems with NFS-Root-Clients
Date: Tue, 27 Aug 2002 18:10:50 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208271756360.18747-100000@kenzo.iwr.uni-heidelberg.de>
References: <95AF67BA7F70D511829B0002A551737001C9C4@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jivg-0003nv-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 09:10:56 -0700
To: Marco.Schwarz@freudenberg.de
In-Reply-To: <95AF67BA7F70D511829B0002A551737001C9C4@faw-e01.faw.freudenberg.de>
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

On Tue, 27 Aug 2002 Marco.Schwarz@freudenberg.de wrote:

> it is not working most of the time, but sometime it is, and some
> days ago it was the other way ... working most of the time, just sometimes
> problems).

Hmm, maybe you should fix this first ! What do you mean by "not working": 
- sometimes it doesn't provide a link at boot time and you have to reboot 
and eventually it will get past the point and afterwards eveything works 
fine or
- it boots fine and there are intermitent problems afterwards or
- something else ?

> Network cards are Intel EEPro100, but we have a lot more of these (also with
> diskless clients, same configuration/kernel), and the problem is happening
> in just this one location ...

IIRC, there are different revisions of the cards, some of them having 
some problems... so it's not sufficient to have another one working well !

> Sending BOOTP requests . OK
> IP-Config: Got BOOTP answer from 192.168.0.235, my adress is 192.168.0.87
> IP-Config: Complete:

Um, the link did work ! Can you try to ping it from the server ? That 
should show if the link is down. Another (better) possibility would be to 
turn on debugging in the network driver (change in source and recompile or 
pass it on the kernel command line), but it depends on the driver that 
you're using. F.e. for Donald Becker's drivers you can use debug level 2 
or 3 to get media related information without getting too much 
uninteresting (for this problem) stuff.

Another unrelated suggestion: can you make sure that you're not running 
any kind of firewall (ipchains/iptables) on the server that could block 
the communication ?

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
