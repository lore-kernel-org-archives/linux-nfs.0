From: business@paul.austin.name
Subject: NFS Mount RPC Timed out problem
Date: Fri, 15 Oct 2004 14:00:13 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <33419.192.168.1.1.1097874013.squirrel@192.168.1.1>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIZBT-0006FS-Tj
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 14:00:19 -0700
Received: from [65.39.240.4] (helo=chief.intranet.paul.austin.name)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CIZBS-0008W5-DU
	for nfs@lists.sourceforge.net; Fri, 15 Oct 2004 14:00:19 -0700
Received: from ssl.paul.austin.name (localhost [127.0.0.1])
	by chief.intranet.paul.austin.name (Postfix) with ESMTP id 794E742750
	for <nfs@lists.sourceforge.net>; Fri, 15 Oct 2004 14:00:13 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

I'm experiencing a RPC: Timed out issue with my system that started
yesterday after I had login issues with my system (which are now fixed),
up until that point NFS was working correctly.

I have turned on debug output on the rpc.mountd but not much seems to be
written out, if anyone knows what I should check in these cases it would
be greatly appreciated, I've googled myself to death trying to find out
the problem.

If there is a FAQ for this problem let me know.

My configuration is as follows.

Gentoo Linx: 2.6.8-r8 (also tried -r3)
nfs-utils: 1.0.6-r4
portmap: 5b-r8


# showmount -e localhost
Export list for localhost:
/home          192.168.1.0/255.255.255.0
/home/projects 192.168.1.0/255.255.255.0

#rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32859  status
    100024    1   tcp  33225  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32860  nlockmgr
    100021    3   udp  32860  nlockmgr
    100021    4   udp  32860  nlockmgr
    100005    1   udp    636  mountd
    100005    1   tcp    639  mountd
    100005    2   udp    636  mountd
    100005    2   tcp    639  mountd
    100005    3   udp    636  mountd
    100005    3   tcp    639  mountd

#cat /etc/hosts.allow
portmap: 192.168.1.0/255.255.255.0
lockd: 192.168.1.0/255.255.255.0
rquotad: 192.168.1.0/255.255.255.0
mountd: 192.168.1.0/255.255.255.0
statd: 192.168.1.0/255.255.255.0

#cat /etc/hosts.deny
portmap: ALL
lockd: ALL
rquotad: ALL
mountd: ALL
statd: ALL

If any more information would be useful please let me know.

Thanks in advance,
Paul



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
