From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: 'random' diskless clients hangs
Date: Tue, 9 Sep 2003 17:25:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309091725.18725.bernd-schubert@web.de>
References: <NEBBIHNAFKJAFOHBHGCOIEKLEFAA.nfsmailinglist@heessels.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wknc-0002EV-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 08:53:00 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wknb-0004JA-Qk
	for nfs@lists.sourceforge.net; Tue, 09 Sep 2003 08:52:59 -0700
Received: from smtp01.web.de ([217.72.192.180]:3635 helo=smtp.web.de)
	by externalmx.vasoftware.com with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 4.22 #1 (Debian))
	id 19wkNv-0004YG-Jz
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 08:26:27 -0700
To: <nfsmailinglist@heessels.com>
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOIEKLEFAA.nfsmailinglist@heessels.com>
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

On Monday 08 September 2003 20:37, nfsmailinglist@heessels.com wrote:
> Help!! We're closing to giving up on NFS.
>
> We have tried multiple NICS and drivers on both server and client
> (eepro100, e100, e1000).
> We have tries both UDP and TCP.
> We have tried multiple versions of nfs-utils.
> We have tried multiple versions of the kernel.
> We have tried multiple clients.
> We have tried multiple switches.
>

Have you already tried to connect the server and one client directly? So using 
a cross-over-cable from the server to one client without any switch between.

Also, is your network really full-duplex? You can figure out using mii-tool.

I would also try if the same problems happen on non-root-nfs clients. So e.g. 
exporting only /usr and /home from the server, using a local 
linux-installation on the client and import those two directories.
Btw, I think I saw in one of your mail, that you are using 4096bytes for rsize 
and wsize as default, setting this to 8192 should increase the probability to 
see the problem occuring faster. I guess later on (when everything is 
working) you won't like to use 4096byte anyway.

Cheers,
	Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
