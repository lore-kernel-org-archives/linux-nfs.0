From: michel ziobudda morelli <michel@ziobudda.net>
Subject: NFS client freeze If I'm not connect to server
Date: Wed, 05 Apr 2006 11:34:21 +0200
Message-ID: <44338F1D.7070107@ziobudda.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FR4NL-0001UN-HU
	for nfs@lists.sourceforge.net; Wed, 05 Apr 2006 02:32:31 -0700
Received: from 213-140-2-69.ip.fastwebnet.it ([213.140.2.69] helo=aa002msg.fastwebnet.it)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FR4NI-00060O-Qy
	for nfs@lists.sourceforge.net; Wed, 05 Apr 2006 02:32:31 -0700
Received: from ms004msg.fastwebnet.it (10.31.40.142) by aa002msg.fastwebnet.it (7.2.069.1)
        id 442150BE00511310 for nfs@lists.sourceforge.net; Wed, 5 Apr 2006 11:32:17 +0200
Received: from [192.168.0.3] (1.10.219.49) by ms004msg.fastwebnet.it (7.2.070)
        id 43F1EB9F0139BD67 for nfs@lists.sourceforge.net; Wed, 5 Apr 2006 11:32:16 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Ok, the subject is strange and sorry for my bad english. But I have this
problem:

I have installed SLES 9 SP2 in a Dell PowerEdge 2800. I have setup 2 NFS
directory: /home/ and /var/sharing/ with normal option
(rw,root_squash,sync). And the server is LDAP server for my user
(login), too. I have installed SUSE 10.0 (not opensuse) onto the client
and mount /home and /var/sharing. The problem is: when I write a file
into NFS share my client freeze. I can do only a brutal reset.
I have tried to change root_squash to no_root_squash and sync to async.
Nothing. Same Problem.

I have make another test: boot client,  before try to write into NFS
share, I "restart" the NFS server service. Magically the write works.

I have make some other test and I have found a strange thing:

- Boot server,
-  boot client.
     - From client (via console)
             - login with root account,
                      - make a ssh connection to the server
                      - into the server I exec tail -f /var/log/message
    - From client (via X11) login with user account (/home/ is via NFS)
    NO FREEZE!!!!!!!!!!

Plz Help me.

Ah, my network is a "internal network", so I have not a gateway for
internet, no DNS. Only IP. I have tried to insert the IP-NameMachine
into /etc/hosts, but the result is the same.

Tnx.
-- 
Michel 'ZioBudda' Morelli                       michel@ziobudda.net
http://www.ziobudda.net                         ICQ: 58351764
http://www.phpbook.it                           FAX: 0291390660
http://www.ajaxblog.it				TEL: 3939890025


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
