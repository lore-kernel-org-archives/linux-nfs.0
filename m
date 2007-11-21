From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Wed, 21 Nov 2007 11:04:55 -0500
Message-ID: <47445727.5090705@oracle.com>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>	<47434ED7.4010100@redhat.com>
	<47435049.1010800@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080308050100050607040009"
Cc: Peter Staubach <staubach@redhat.com>,
	Wendy Cheng <s_wendy_cheng@hotmail.com>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ius5m-0001vv-Gc
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 08:06:22 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ius5q-0003ET-3g
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 08:06:28 -0800
In-Reply-To: <47435049.1010800@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------080308050100050607040009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Wendy-

Wendy Cheng wrote:
> Peter Staubach wrote:
>> Wendy Cheng wrote:
>>>  
>>>> top - 15:50:56 up 20 days,  1:33,  9 users,  load average: 3.42, 
>>>> 2.95, 2.38
>>>>
>>>> 19200 geo0501   15   0 75076 5224 3480 S    2  0.1   0:07.94 
>>>> smbd                2336 root      10  -5     0    0    0 S    1  
>>>> 0.0  57:07.70 kjournald           2334 root      10  -5     0    
>>>> 0    0 S    1  0.0  33:19.89 kjournald           2279 root      10  
>>>> -5     0    0    0 S    0  0.0  15:10.98 md0_raid1           2283 
>>>> root      10  -5     0    0    0 S    0  0.0  24:45.79 
>>>> md1_raid1           3935 root      15   0     0    0    0 S    0  
>>>> 0.0  14:04.25 nfsd                3943 root      15   0     0    
>>>> 0    0 S    0  0.0  14:18.43 nfsd                3947 root      15   
>>>> 0     0    0    0 S    0  0.0  13:57.06 nfsd                8325 
>>>> ed0127    15   0 75044 4812 3264 S    0  0.1   0:01.29 
>>>> smbd                
>>> Intuitively (based on ext3's journal threads info above) I would 
>>> suspect this is due to the change of the export default option from 
>>> "async" to "sync" between 2.6.9 and 2.6.18 kernels.  So go to your 
>>> /etc/exports file and explicitly set the export option to "async" to 
>>> see whether you can get the performance back.
>>>
>>> e.g. changes "/server *(rw)" to "/server *(async, rw)".
>> While this may or may not restore your performance aspects, it
>> is not safe to make this change.  The change was made for a
>> reason.
 >
> Not to start a flame war :) but please read his email. His *old* system, 
> that uses "async" option", has been running fine for several years. Why 
> all of sudden, an "async" option is such a big issue ?

That means his old system would have been exposed to data corruption 
issues if it crashes (panic, power outage, etc).  Using "sync" became 
default because async is inherently careless about data integrity.  The 
data loss is often entirely silent.

This is explained in the Linux NFS FAQ, question B6.

See http://nfs.sourceforge.net/index.php#faq_b6

It's another case of where we perform better in older kernels but we are 
more correct in recent kernels... but our users don't appreciate the 
correctness improvement :-)

> -- Wendy
>> Please any and all other possibilities before making this change.
>> It is not free.

It's a reasonable *experiment* to try adding the "async" export option. 
  That would identify the source of the performance loss.  It's almost 
never a good choice to use "async" in production.

--------------080308050100050607040009
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


--------------080308050100050607040009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--------------080308050100050607040009
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--------------080308050100050607040009--


