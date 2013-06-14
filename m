Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:25382 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3FNRFd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jun 2013 13:05:33 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51BAB0BC.1010303@gmail.com>
Date: Fri, 14 Jun 2013 13:05:28 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <5A1575CF-0400-48CE-B18B-5B26C92D152A@oracle.com>
References: <51BAAFFC.6060208@gmail.com> <51BAB0BC.1010303@gmail.com>
To: John Haiducek <jhaiduce@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 14, 2013, at 1:57 AM, John Haiducek <jhaiduce@gmail.com> wrote:

> I'm able to use NFSv4 just fine using AUTH_SYS, but when I turn on sec=krb5 I can't mount at all. I'm using Debian Wheezy.
> 
> I'm able to use Kerberos just fine for other things (like ssh), and forward and reverse DNS appears to be working correctly per the host command. However, the NFS mount command fails differently when I add my host's IP address to /etc/hosts (the same host is both client and server). Specifically, when the address is in /etc/hosts the NFS server fails immediately with a "permission denied" error, while if the address is not present in /etc/hosts the mount command hangs forever and never returns. This makes it seem like mount.nfs or rpc.gssd can't find the host in DNS even though other programs can. How can this be?
> 
> In /var/log/syslog I see this:
> 
> |Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clntd
> Jun 11 20:28:12 tbm rpc.idmapd[8954]: Stale client: d
> Jun 11 20:28:12 tbm rpc.idmapd[8954]: #011->  closed /var/lib/nfs/rpc_pipefs/nfs/clntd/idmap
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:12 tbm rpc.gssd[8959]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clntc
> Jun 11 20:28:12 tbm rpc.idmapd[8954]: Stale client: c
> Jun 11 20:28:12 tbm rpc.idmapd[8954]: #011->  closed /var/lib/nfs/rpc_pipefs/nfs/clntc/idmap
> Jun 11 20:28:13 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:13 tbm rpc.idmapd[8954]: New client: e
> Jun 11 20:28:13 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:13 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e4570 data 0x7fffbc4e4440
> Jun 11 20:28:13 tbm rpc.idmapd[8954]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnte/idmap
> Jun 11 20:28:13 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e4570 data 0x7fffbc4e4440
> Jun 11 20:28:13 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:13 tbm rpc.idmapd[8954]: New client: f
> Jun 11 20:28:13 tbm rpc.gssd[8959]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnte)
> Jun 11 20:28:13 tbm rpc.gssd[8959]: handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
> Jun 11 20:28:13 tbm rpc.gssd[8959]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnte)
> Jun 11 20:28:13 tbm rpc.gssd[8959]: process_krb5_upcall: service is '<null>'
> Jun 11 20:28:23 tbm rpc.gssd[8959]: Name or service not known while getting full hostname for 'tbm.enterprise.local'

gssd thinks your client's hostname is "tbm.enterprise.local," which has no DNS entry.

> Jun 11 20:28:23 tbm rpc.gssd[8959]: ERROR:
> gssd_refresh_krb5_machine_credential: no usable keytab entry found in
> keytab /etc/krb5.keytab for connection with host tbm.enterprise.local
> Jun 11 20:28:23 tbm rpc.gssd[8959]: ERROR: No credentials found for connection to server tbm.enterprise.local

This suggests you don't have a keytab on your client, or you have one, but it doesn't have an entry that can be used as root's credential.  Could be a result of the DNS lookup problem above.

> Jun 11 20:28:23 tbm rpc.gssd[8959]: doing error downcall
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.idmapd[8954]: Stale client: f
> Jun 11 20:28:23 tbm rpc.idmapd[8954]: #011->  closed /var/lib/nfs/rpc_pipefs/nfs/clntf/idmap
> Jun 11 20:28:23 tbm rpc.gssd[8959]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clntf
> Jun 11 20:28:23 tbm rpc.idmapd[8954]: Stale client: e
> Jun 11 20:28:23 tbm rpc.idmapd[8954]: #011->  closed /var/lib/nfs/rpc_pipefs/nfs/clnte/idmap
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: dir_notify_handler: sig 37 si 0x7fffbc4e9570 data 0x7fffbc4e9440
> Jun 11 20:28:23 tbm rpc.gssd[8959]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnte|
> 
> Can anyone point me in the right direction for getting this working?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




