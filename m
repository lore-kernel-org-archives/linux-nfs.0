From: Seb James <seb@peak.uklinux.net>
Subject: NFS (and NIS) client causes server to semi-hang
Date: 12 Jun 2003 11:17:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055413060.1984.34.camel@circle.hypercube>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from s4.uklinux.net ([80.84.72.14] helo=mail2.uklinux.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QP9Q-0000fZ-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 03:17:48 -0700
Received: from localhost (s4.uklinux.net [127.0.0.1])
	by mail2.uklinux.net (Postfix) with ESMTP id 491D4409FD7
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 10:17:45 +0000 (UTC)
Received: from mail2.uklinux.net ([127.0.0.1])
 by localhost (s4.uklinux.net [127.0.0.1:10024]) (amavisd-new) with ESMTP
 id 11427-05 for <nfs@lists.sourceforge.net>;
 Thu, 12 Jun 2003 11:17:43 +0100 (BST)
Received: from [192.168.0.2] (unknown [195.137.117.140])
	by mail2.uklinux.net (Postfix) with ESMTP id 65742409FC2
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 10:17:43 +0000 (UTC)
To: NFS Mailing list <nfs@lists.sourceforge.net>
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

Hello,

I've come across a rather worrying problem.

I have a small network of computers, sitting behind a adsl modem/router.
The internal ip domain is hypercube, I have also called the yp domain
hypercube as it is the identical set of machines.

The server is:

circle.hypercube 

nis server, nfs fileserver, dhcp server, firewall. 

I know it shouldn't be a firewall at the same time as all those other
functions, but it is for now as I want to use it as a stand alone
machine if nothing else is running. It's running redhat 7.2, fully
updated with security patches. Kernel version is 2.4.20-18.7 (a redhat
precompiled kernel).

The two clients are:

darius:    desktop machine running fully updated redhat 9.0 installation
herodotus: a laptop also with updated redhat 9.0.

Herodotus is set up to mount /home and a directory called /data from
circle, with the following lines in /etc/fstab:

circle:/data            /data                   nfs     defaults        0 0
circle:/home		/home			nfs	defaults	0 0

It is also set up as an nis client, with the following in /etc/yp.conf

domain hypercube server circle.hypercube

And it works just fine, so I believe the server is correctly set up.

Darius has the same set-up as herodotus, but......

Neither nfs nor ypbind function.

Trying to mount a volume:

[root@darius /]# mount /data/
pmap_getmaps rpc problem: RPC: Timed out
mount: RPC: Port mapper failure - RPC: Timed out
[root@darius /]#

NB: a portmapper is running on both darius and circle (and herodotus,
too).

Trying to start ypbind:

[root@darius /]# service ypbind start
Setting NIS domain name hypercube:             [  OK  ]
Binding to the NIS domain:                     [  OK  ]
Listening for and NIS domain server........    [FAILED]
[root@darius /]#


Now, when I try to do *either* of these, the server starts to play up.
It begins to timeout on almost anything network or authentication
related. For example, to bring up a new terminal window in X takes at
least a minute and to then access a website using, say lynx, takes a
similar time. I'm confused as to why both ypbind and mounting a volume
on the server should be able to cause this denial of service.

Does anyone have any ideas?

Also, is there a suitable NIS related list to post this message to, as I
think it's relevant for that, too.

best regards,

Seb James.

-- 
Seb James <seb@peak.uklinux.net>



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
