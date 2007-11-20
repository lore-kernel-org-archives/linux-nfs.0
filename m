From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Tue, 20 Nov 2007 16:17:11 -0500
Message-ID: <47434ED7.4010100@redhat.com>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, wcheng@redhat.com
To: Wendy Cheng <s_wendy_cheng@hotmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuaT4-0007N5-1O
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 13:17:14 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuaT9-0005XU-NH
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 13:17:20 -0800
In-Reply-To: <BAY104-W43766F661E50E7FFCDA8EBA7F0-MsuGFMq8XAE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Wendy Cheng wrote:
>   
>> top - 15:50:56 up 20 days,  1:33,  9 users,  load average: 3.42, 2.95, 2.38
>>
>> 19200 geo0501   15   0 75076 5224 3480 S    2  0.1   0:07.94 smbd               
>>  2336 root      10  -5     0    0    0 S    1  0.0  57:07.70 kjournald          
>>  2334 root      10  -5     0    0    0 S    1  0.0  33:19.89 kjournald          
>>  2279 root      10  -5     0    0    0 S    0  0.0  15:10.98 md0_raid1          
>>  2283 root      10  -5     0    0    0 S    0  0.0  24:45.79 md1_raid1          
>>  3935 root      15   0     0    0    0 S    0  0.0  14:04.25 nfsd               
>>  3943 root      15   0     0    0    0 S    0  0.0  14:18.43 nfsd               
>>  3947 root      15   0     0    0    0 S    0  0.0  13:57.06 nfsd               
>>  8325 ed0127    15   0 75044 4812 3264 S    0  0.1   0:01.29 smbd            
>>     
>
> Intuitively (based on ext3's journal threads info above) I would suspect this is due to the change of the export default option from "async" to "sync" between 2.6.9 and 2.6.18 kernels.  So go to your /etc/exports file and explicitly set the export option to "async" to see whether you can get the performance back.
>
> e.g. changes "/server *(rw)" to "/server *(async, rw)".

While this may or may not restore your performance aspects, it
is not safe to make this change.  The change was made for a
reason.

Please any and all other possibilities before making this change.
It is not free.

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

