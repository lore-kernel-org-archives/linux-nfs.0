From: David McGiven <davidmcgivenn@gmail.com>
Subject: NFSv4 client & Netapp Server -> Problem with id mapping
Date: Wed, 19 Jan 2011 11:10:51 +0100
Message-ID: <F765C6E3-C3AF-4F6E-A775-402F56D54E5D@gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55914 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749Ab1ASKK7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jan 2011 05:10:59 -0500
Received: by wwa36 with SMTP id 36so684749wwa.1
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jan 2011 02:10:58 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS Users,

I have a Linux client (ubuntu 8.04) that correctly mounts through  
NFSv3 an NFS share from a NetApp Filer (DataONTAP 7.2.1.1).

Due to firewall issues, I now need to use NFSv4 instead of v3.  
However, I'm having the problem of seeing all the files owned by  
nobody/nogroup.

Please, could anyone provide some advice ?

The command I'm using to mount it is :
mount -t nfs4 -o intr,proto=tcp filer:/vol/people /people/

These are the NetApp options :
nfs.v4.acl.enable            off
nfs.v4.enable                on
nfs.v4.id.domain             localdomain
nfs.v4.read_delegation       off
nfs.v4.write_delegation      off

The filer exports are :

/vol/people     -sec=sys,rw=machine1:machine2,root=master

In the linux box I've double checked that /etc/idmpad.conf domain is  
the same : "localdomain".

Just in case, I'm running the rpc.impad daemon on the linux client.  
This is the output for a single 'mount' and a single 'ls'

root@machine1:~# /usr/sbin/rpc.idmapd -vvvv -f
rpc.idmapd: libnfsidmap: using domain: localdomain

rpc.idmapd: libnfsidmap: using translation method: nsswitch

rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: New client: 15
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt15/idmap
rpc.idmapd: New client: 16
rpc.idmapd: nss_getpwnam: name 'root@localdomain' domain  
'localdomain': resulting localname 'root'

rpc.idmapd: Client 15: (user) name "root@localdomain" -> id "0"
rpc.idmapd: Client 15: (group) name "nobody" -> id "65534"
rpc.idmapd: nss_getpwnam: name 'nobody' domain 'localdomain':  
resulting localname '(null)'

rpc.idmapd: nss_getpwnam: name 'nobody' does not map into domain  
'localdomain'

rpc.idmapd: Client 15: (user) name "nobody" -> id "65534"


Could someone please help me ? I'm puzzled because NFSv3 deals  
perfectly with user names and groups.

Well, Thanks.

Best,
David
