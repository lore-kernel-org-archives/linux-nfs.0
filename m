From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Problems getting started with booting via NFS
Date: Wed, 27 Aug 2003 21:08:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200308272108.56470.bernd-schubert@web.de>
References: <6.0.0.10.0.20030827134940.0264cde0@helmholtz.hia.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19s5fY-0006tt-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Aug 2003 12:09:24 -0700
Received: from smtp03.web.de ([217.72.192.158] helo=smtp.web.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19s5fY-0007RM-29
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 12:09:24 -0700
Received: from [80.140.6.68] (helo=bathl.lan.fli4l)
	by smtp.web.de with asmtp (WEB.DE 4.99 #448)
	id 19s5f1-00055L-00
	for nfs@lists.sourceforge.net; Wed, 27 Aug 2003 21:08:51 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <6.0.0.10.0.20030827134940.0264cde0@helmholtz.hia.rwth-aachen.de>
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

On Wednesday 27 August 2003 13:59, Lars Meinecke wrote:
> Hello,
>
> I'm quite new to Linux in general, so may be one or the other question may
> sound quite simple to you. Nevertheless:
>
> My situation:
> I have a Workstation with static IP runnning RedHat 9.0. This is the NFS
> Server.
> Secondly I have a singele-chip PC with a flash ROM running RedBoot which
> then loads the Linux Busybox system if not interrupted. This is the client
> system.

So does your client already do a dhcp- and tftp-request? And would it accept 
etherboot-images? If it does it might become rather easy.

>
> What I want to do:
> I'd like to have the client system booting via NFS from the server system,
> so that I can develop software and perhaps alter the operating system for
> the single-chip PC on the server system and thus reducing time for
> development.
>
> What I'm searching for:
> ... is something like a step-by-step instruction set on how to reach the
> above mentioned system configuration.
> I already read through a lot of how-to's and books, but still I find
> setting up the system quite complicated... - may be I worked to long with
> M$...
>

Setting up nfs and tftpboot is really easy. The most difficult part was to 
find out als the stuff about etherboot since I didn't find a nice howto. 
Getting dhcp properly configured also required some reading.
If I have some more time I will write a nice howto how our cluster works -- 
our cliens also boot via network, but the server and clients use a shared 
root-environment, based on nfsd and clusternfsd, both are running on the 
server. Unfortunality there's always so much other stuff to do...

However I already wrote some documentation for the other admins in our group 
and that might help Lars a bit. Lars, if you want, you can contact me in 
German and ask some further questions :)

Bernd



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
