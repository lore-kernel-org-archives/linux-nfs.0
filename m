From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: Thu, 1 Jun 2006 18:50:57 +0000 (UTC)
Message-ID: <loom.20060601T203856-958@post.gmane.org>
References: <loom.20060531T205740-641@post.gmane.org> <loom.20060601T155144-450@post.gmane.org> <447EF8CA.3020200@redhat.com> <loom.20060601T164005-982@post.gmane.org> <447F0E3D.9070809@redhat.com> <loom.20060601T175939-701@post.gmane.org> <447F2268.4090401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FlsGY-0003Lh-J7
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 11:51:30 -0700
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FlsGY-000150-2t
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 11:51:30 -0700
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FlsGE-0006gy-Uv
	for nfs@lists.sourceforge.net; Thu, 01 Jun 2006 20:51:10 +0200
Received: from rev2009237.secyt.gov.ar ([rev2009237.secyt.gov.ar])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 20:51:10 +0200
Received: from mstorti by rev2009237.secyt.gov.ar with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 01 Jun 2006 20:51:10 +0200
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

Peter Staubach <staubach <at> redhat.com> writes:

> Can you get a raw tethereal capture file which shows the issue?  Perhaps
> a capture which includes reading the original contents of the file and
> then reading it again after the file is modified on the server or by
> another client?  Perhaps from that we can get some clues as to where the
> problem might be.

OK. Good idea. I added a line with `#jaja12' to my file `~/.bashrc'
and verified that all nodes see the change. Then I modify the line
with Emacs in the server to `#jaja13' and svae, then to `#jaja14' and
save, and to `#jaja15'. Some nodes acknowledge the change but others
not. If I do a `parallel grep' I obtain the following

================================================================
[mstorti@aquiles ~]$ pdsh -a 'grep jaja ~/.bashrc'
node2: # jaja12
node1: # jaja15
node9: # jaja15
node10: # jaja14
node11: # jaja12
node13: # jaja15
node20: # jaja15
node3: # jaja15
node17: # jaja12
node4: # jaja15
node7: # jaja12
node8: # jaja15
node18: # jaja15
node6: # jaja12
node14: # jaja14
node12: # jaja15
node16: # jaja14
node5: # jaja15
node19: # jaja14
node15: # jaja15
[mstorti@aquiles ~]$ 
================================================================

So I choose for instance `node2' which has still the "# jaja12"
string. Then 

* I open a shell in node2,  
* Launch a `tethereal' filtering the
        communication between the server (192.168.0.201) and node2
        (192.168.0.2).
* I do a grep in node2

    [mstorti@node2 ~]$ grep jaja .bashrc
    # jaja12
    [mstorti@node2 ~]$ 

* and I close the `tethereal'. 

What I obtain is the following:

================================================================
[root@aquiles ~]# tethereal -i eth0 host aquiles and host node2
Capturing on eth0
  0.000000  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  2.490445 192.168.0.201 -> 192.168.0.2  Rlogin Data: g
  2.490548  192.168.0.2 -> 192.168.0.201 Rlogin Data: g
  2.490567 192.168.0.201 -> 192.168.0.2  Rlogin Data: rep jaja .bashrc\n
  2.490794  192.168.0.2 -> 192.168.0.201 Rlogin Data: rep jaja .bashrc\r\n
  2.491546  192.168.0.2 -> 192.168.0.201 NFS V3 GETATTR Call, FH:0x76120002
  2.491597 192.168.0.201 -> 192.168.0.2  NFS V3 GETATTR Reply (Call In 6)
  2.491669  192.168.0.2 -> 192.168.0.201 TCP 1023 > nfs [ACK] Seq=108 Ack=116
Win=32645 Len=0 TSV=612612 TSER=27245753
  2.491676  192.168.0.2 -> 192.168.0.201 NFS V3 GETATTR Call, FH:0xf8ea8c0a
  2.491701 192.168.0.201 -> 192.168.0.2  NFS V3 GETATTR Reply (Call In 9)
  2.529519  192.168.0.2 -> 192.168.0.201 TCP 1023 > nfs [ACK] Seq=216 Ack=232
Win=32674 Len=0 TSV=612616 TSER=27245753
  2.536043 192.168.0.201 -> 192.168.0.2  TCP 1023 > login [ACK] Seq=18 Ack=19
Win=1460 Len=0 TSV=27245757 TSER=612612
  2.536144  192.168.0.2 -> 192.168.0.201 Rlogin Data: # jaja12\r\n[mstorti@node2
~]$ 
  2.539333 192.168.0.201 -> 192.168.0.2  TCP 1023 > login [ACK] Seq=18 Ack=48
Win=1460 Len=0 TSV=27245757 TSER=612616
  7.549413  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  7.549424  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  7.549428  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  7.549431  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  7.549435  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
  7.549438  192.168.0.2 -> 192.168.0.201 UDP Source port: 32769  Destination
port: 8649
20 packets captured
[root@aquiles ~]# 
================================================================

Do you see something in there? I am studying it, but I didn't know
enough of NFS for understaing it yet. 

Thank for your help, Mario




-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
