From: Guntsche Michael <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Kerberos authentication Problem with nfs3/4
Date: Sat, 18 Oct 2008 14:57:08 +0200
Message-ID: <23D48171-03B8-4E14-B56C-081CF004D625@it-loops.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:44205
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751252AbYJRNDx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2008 09:03:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list,

I had my kerberised NFS4 and NFS3 setup running in test mode up to the  
end of April.
After seeing that there have been changes made to the recent code to  
make NFS3+Kerberos working without sec=sys I tried to mount my exports  
again with kerberos auth enabled.

But for some reason the setup is no longer working. My KDC has not  
changed at all, and I did not change a thing in my NFS config as well.

My current setup:
Server running 2.6.27
nfs-utils 1.1.3 from debian.

klist -k from the server:
=========================

---  
--------------------------------------------------------------------------
   3 nfs/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org (DES cbc mode with CRC-32)
   4 host/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org (Triple DES cbc mode with HMAC/ 
sha1)
   4 host/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org (DES cbc mode with CRC-32)
   4 imap/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org (Triple DES cbc mode with HMAC/ 
sha1)
   4 imap/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org (DES cbc mode with CRC-32)


For testing purposes I tried mounting the export from the server  
itself which also did not work.


exports:
========

/srv/nfs4   
*(sec=krb5:sys,rw,async,fsid=0,insecure,crossmnt,no_subtree_check)
/srv/nfs4/media   
*(sec=krb5:sys,rw,async,insecure,crossmnt,no_subtree_check)


Mount command from the server to itself (sec=sys works):
========================================================

mount -t nfs4 -osec=krb5 gibson:/media/ /mnt


rpc.gssd -vv -f:
================

beginning poll
handling krb5 upcall
Full hostname for 'gibson.comsick.at' is 'gibson.comsick.at'
Full hostname for 'gibson.comsick.at' is 'gibson.comsick.at'
Key table entry not found while getting keytab entry for 'root/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org 
'
Success getting keytab entry for 'nfs/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org'
Successfully obtained machine credentials for principal 'nfs/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org 
' stored in ccache 'FILE:/tmp/krb5cc_machine_COMSICK.AT'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_COMSICK.AT' are good  
until 1224370141
using FILE:/tmp/krb5cc_machine_COMSICK.AT as credentials cache for  
machine creds
using environment variable to select krb5 ccache FILE:/tmp/ 
krb5cc_machine_COMSICK.AT
creating context using fsuid 0 (save_uid 0)
creating tcp client for server gibson.comsick.at
creating context with server nfs-F/bOXVQdVXiG9iZHpwcNGF6hYfS7NtTn@public.gmane.org
WARNING: Failed to create krb5 context for user with uid 0 for server  
gibson.comsick.at
WARNING: Failed to create krb5 context for user with uid 0 with  
credentials cache FILE:/tmp/krb5cc_machine_COMSICK.AT for server  
gibson.comsick.at
WARNING: Failed to create krb5 context for user with uid 0 with any  
credentials cache for server gibson.comsick.at
doing error downcall
Failed to write error downcall!
destroying client clntbe
destroying client clntbd


rpc.svcgsdd -vvf:
=================

leaving poll
handling null request
sname = nfs/gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org
WARNING: get_ids: failed to map name 'nfs/ 
gibson.comsick.at-tv3pJBznBAdW35wihSpRnA@public.gmane.org' to uid/gid: Invalid argument
sending null reply
writing message: \x  
\x608201fb06092a864886f71201020201006e8201ea308201e6a003020105a10302010e 
a20703050020000000a3820116618201123082010ea003020105a10c1b0a434f4d5349434b2e4154a2233021a003020103a11a30181b036e66731b11676962736f6e2e636f6d7369636b2e6174a381d33081d0a003020101a103020103a281c30481c02e9b04122fe2e7937374adb7e455e90285dc15d51bcfbe4898a7fba45ea1026d4ce1620646c7dd3286b9878fa7a4f8f31922879ffb70e6ba6c726e9685aad92fd7c19264e1f98364b04d7add847749d655c30a11d15f7d7297f77a9e8c8d4c1d20d08e3747c098eaf18627802cf878955ef5ccec35fe6505d86f15068dee067795ee5909a1a16705873981838b56423023668ba5a291e9281ae41ec4b82d343918a20046e8e7df62bf50b337f528d109fa410e4f6eff378060bac51a50902789a481b63081b3a003020101a281ab0481a855ca1c7e0a3ac10779318f985d3bbb0ef843bd01601019226611c1e6817b461002be334966b1dcc1dc2aaaeb70269b50fdaa6941fc3d898cda478b17b9080b3340f9818470bd7d9bd21fbad3586f422551eff5be7a582cc1a046338a
 4f47a228d17967c623165415059297e0b1966baa303ee37c51d949b27c5af830bbd579ddbed86d06653b4bd74a9601f83cf61fb730bd5275ddc48b9740734d07afe20344681cbaa3e0f5287a 
  2147483647 131072 0 \x \x
finished handling null request
entering poll

the mount command returns with

mount.nfs4: access denied by server while mounting gibson:/media/

I tried downgrading the kerberos server and also the nfs-utils  
version. I also tried it with an older kernel version (2.6.25) but the  
result was the same. All other kerberos stuff (ssh, imap) is working  
so I think it has something to to with the nfs setup here.



As you can see the nfs entry is there too.




