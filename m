From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Wed, 10 Oct 2007 22:49:41 -0400
Message-ID: <470D8F45.8020202@oracle.com>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>	<18186.56139.301135.961540@notabene.brown>	<5847045D-72E9-4322-AB08-F8952C26AA44@oracle.com>
	<18189.32027.462332.151295@notabene.brown>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------060307020507080003090307"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ifo8T-0000iA-Kv
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:50:53 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ifo8X-0007GZ-RQ
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 19:50:58 -0700
In-Reply-To: <18189.32027.462332.151295@notabene.brown>
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

This is a multi-part message in MIME format.
--------------060307020507080003090307
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
>>> By the by, when testing what the current code does, I discovered that
>>> if
>>>
>>>       mount server:/path /dir
>>>
>>> falls back to v2 because the default (v3) doesn't work, then
>>>      umount /dir
>>>
>>> fails with
>>>
>>>      umount.nfs: Server failed to unmount 'server:/path'
>>>
>>> which is a worry.
>> OK, it's not supposed to do that either, and I never saw that  
>> behavior during testing.  (Well, actually we did see it, but it was  
>> only with NFSv4, and is supposed to be fixed by one of the patches in  
>> the last set I sent you).
>>
>>> I think there are two problem here:
>>>   1/ we should fall back to v2 umount if v3 fails (well, the MOUNT
>>>      versions  are different, but you know what I mean).
>>>   2/ If the call to the server fails, we should still unmount the
>>>      filesystem (call del_mtab .... not a good choice for the name
>>>      of the function that does the actual unmount...)
>>> Thoughts?
>> First I would like to understand precisely why umount is failing.  In  
>> this case, mount.nfs should rewrite the mount options, then post them  
>> in /etc/mtab so that umount can use the same service endpoint when  
>> doing the unmount.  The umount should then use the post-fallback  
>> options, and succeed.  Does "umount -v" provide any helpful
>> information?
> 
> (remembering this is with the binary mount interface, not the new
> ASCII one) the updated mount options are *not* written to /etc/mtab.
> It just has 
> 
>  eli:/var/tmp/samba /mnt nfs rw,addr=192.168.1.3 0 0
> 
> nfsvers=2 has not been added.
> umount -v says:
> umount.nfs: trying 192.168.1.3 prog 100005 vers 3 prot UDP port 723
> umount.nfs: Server failed to unmount 'eli:/var/tmp/samba'

OK... the new information is that this is failing with the legacy mount. 
  That makes a little more sense.

>> Certainly it would be good to rename del_mtab() !
>>
>> I also agree that it would be an overall improvement if the RPC  
>> umount request did not determine whether or not umount also tries to  
>> detach the local file system.  I don't see any good reason to link  
>> the two.
> 
> I've broken the link, so the unmount now succeeds.  It would be good
> to get it to send the right request to the server though, either by
> recording the protocol in mtab, or using probe_mntport or similar.

Yeah, that's odd.  It is supposed to be probing the server's mountd in 
nfs_call_umount.  The problem may be that it's only trying a single 
mount RPC (for vers=3), and not doing any kind of version fallback.

--------------060307020507080003090307
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
email;internet:chuck dot lever at nospam oracle dot com
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------060307020507080003090307
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------060307020507080003090307
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------060307020507080003090307--
