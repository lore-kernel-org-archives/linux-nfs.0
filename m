From: Wendy Cheng <s_wendy_cheng@hotmail.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Tue, 20 Nov 2007 20:22:37 +0000
Message-ID: <BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, wcheng@redhat.com
To: <rps-G7wE2RHCdwNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuZcf-0001Ws-2c
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 12:23:05 -0800
Received: from bay0-omc1-s26.bay0.hotmail.com ([65.54.246.98])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuZcj-00037N-VS
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 12:23:11 -0800
In-Reply-To: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>



> 
> top - 15:50:56 up 20 days,  1:33,  9 users,  load average: 3.42, 2.95, 2.38
> 
> 19200 geo0501   15   0 75076 5224 3480 S    2  0.1   0:07.94 smbd               
>  2336 root      10  -5     0    0    0 S    1  0.0  57:07.70 kjournald          
>  2334 root      10  -5     0    0    0 S    1  0.0  33:19.89 kjournald          
>  2279 root      10  -5     0    0    0 S    0  0.0  15:10.98 md0_raid1          
>  2283 root      10  -5     0    0    0 S    0  0.0  24:45.79 md1_raid1          
>  3935 root      15   0     0    0    0 S    0  0.0  14:04.25 nfsd               
>  3943 root      15   0     0    0    0 S    0  0.0  14:18.43 nfsd               
>  3947 root      15   0     0    0    0 S    0  0.0  13:57.06 nfsd               
>  8325 ed0127    15   0 75044 4812 3264 S    0  0.1   0:01.29 smbd            

Intuitively (based on ext3's journal threads info above) I would suspect this is due to the change of the export default option from "async" to "sync" between 2.6.9 and 2.6.18 kernels.  So go to your /etc/exports file and explicitly set the export option to "async" to see whether you can get the performance back.

e.g. changes "/server *(rw)" to "/server *(async, rw)".

-- Wendy


> 
> This server  was installed with Suse 9.1 (linux 2.6.4-52, nfs-utils-1.0.6-103)
> and worked well for a couple of years.
> Then I had to upgrade it (since 9.1 was no longer being updated) and I
> installed 10.1 (linux 2.6.18.8-0.7, nfs-utils-1.0.10-22).
> 
> This upgrade caused some serious performance problem (I suspect related
> to locks).  The most obvious problem is that it can take a long time
> for a KDE user to login (5 minutes or more !), when a number of users
> login at the same time (e.g. a classroom with 16 students). KDE seems
> to spend that time writing and rewriting files in ~/.kde/share/ .
> 
> I know that the problem is related to the change of version, because
> I could boot the old system (it is still installed in another partition)
> and than it worked well again. Samba doesn't seem to be affected, since
> the windows users don't complain.
> 
> I tried to ask on the suse mailing list and newsgroup if someone else
> had the same problem, or if someone had a similar setup working well,
> but I didn't get any useful answer. 
> 
> 
> I don't know what to do about this. Things I thought of trying:
> 
>  - install 10.2 (from scratch)
> 
> I did this, and not only it did not solve the problem, but also, now 
> I can't boot the 9.1 version, because fsck complains that the file
> systems are using features that it doesn't understand.
> 
>  - downgrade to 10.0
> 
>  - downgrade to 9.3 or 9.1 (but since these are no longer being updated,
>    I have to put the server in a private network, close ssh, etc. and
>    even then it is somewhat dangerous.)
> 
> 
> I also installed another PC with all these versions and I tried to
> check which versions have problems. But the tests I did with this
> computer were not conclusive. Maybe because it is not the same
> hardware (32-bit version) or because I can't duplicate the same load.
> 
>  
> 
> Thanks in advance for any suggestions
> 
> -- 
> rps
> 
> 
> 
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

