From: Andy Kennedy <akennedy@techmoninc.com>
Subject: Re: Battered in Brimingham. . .
Date: Wed, 05 Sep 2007 10:28:51 -0500
Message-ID: <46DECB33.3000800@techmoninc.com>
References: <46DDD27B.5000100@techmoninc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISwn1-0007Xw-OA
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 08:27:35 -0700
Received: from smtpauth02.prod.mesa1.secureserver.net ([64.202.165.182])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1ISwn5-0004dd-Jt
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 08:27:40 -0700
In-Reply-To: <46DDD27B.5000100@techmoninc.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Andy Kennedy wrote:
> Okay, I've done this before -- hundreds of times. . . all with Slackware 
> -- the latest one was 10.2 (I think).  Before, I've never had to do any 
> configuration but just add the clients to the exports file, make sure 
> that NFS was built into the Linux kernel (with the TCP support for it) 
> -- then continue on my happy way with setting up my fstab in the client 
> to mount the shares at boot. . .
>
> HOWEVER,
> Now I'm working with an ARM system.  It took great pains to build all 
> the utils (on an external USB drive with a native compiler) needed so 
> that nfs-tools would build.  I believe that I have the tools configured 
> built correctly because I can, in my /etc/exports file, put the line:
> /www/flashcard 127.0.0.1(rw,no_root_squash,sync,insecure)
> then execute the command:
> mount 127.0.0.1:/www/flashcard /mnt
> and get a nice shiny new mount via NFS on my /mnt.
>
> Okay, this I tried after hours upon hours of attempting to get one of 
> two systems to mount /www/flashcard (1) a SBC with only PPP over async 
> and a null modem cable and (2) my host via a network connection.  The 
> results are the same -- the client reports that it "Cannot read super 
> block" after a long delay and the only thing in the server log file is 
> "authenticated mount request from ...".
>
> My first though:  I've screwed something up on the ARM. . . okay switch 
> gears and plug in my computer as the server, and another computer on the 
> network as the client.  Same results.
>
> What am I doing wrong here?
>
> TIA,
> Andy
>
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>   
Found it.  For anyone who may be searching for my solution there were 
two separate issues here:

1) Desktop -> Desktop via ethernet:
This issue was due to the fact that we currently don't have a DNS server 
providing local names.  After adding the host name to the /etc/hosts 
file, we were able to connect.

2) Desktop -> SBC via serial cable:
Unfortunately, the default install for the network configuration was 
all: PARANOID in /etc/host.deny.  I did do a vi /etc/host* but must have 
quit out before I got to the deny file. . .

Bummer man. . . there's three days of my life I cannot get back.


Andy

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
