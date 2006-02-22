From: Ramon van Alteren <ramon@vanalteren.nl>
Subject: Re: Writing to an NFS share truncates files on >8Tb Raid +
 LVM2
Date: Wed, 22 Feb 2006 14:08:34 +0100
Message-ID: <43FC6252.2030104@vanalteren.nl>
References: <43FC3ED3.2060908@vanalteren.nl> <111aefd0602220459s1786fe4ewddc5c21698002e27@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBtjT-0006l8-Ck
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:08:39 -0800
Received: from cust.92.104.adsl.cistron.nl ([195.64.92.104] helo=router.forgottenland.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBtjR-0007Qc-Tq
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:08:39 -0800
To: Chris Penney <penney@msu.edu>, nfs@lists.sourceforge.net
In-Reply-To: <111aefd0602220459s1786fe4ewddc5c21698002e27@mail.gmail.com>
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

Hi Chris & Chikama,

Chris Penney wrote:

> I would highly recommend you use jfs instead of reiserfs (or xfs) for 
> an NFS shared volume.  I have several >8TB NFS file servers and jfs, 
> in my testing, is the only free file system (ie. not vxfs) that has 
> top performance (xfs & jfs are about equal) and the best reliability 
> (rebooting the NFS server caused no corruption in our testing while 
> rebooting with xfs frequently caused nulled zones in files).

Anybody any experience with ext3 on filesystems >8Tb.
Chikama pointed me to the explanation on why this doesn't work with 
reiserfs.

But now I need to figure out which filesystem I will use.
Testing reveals that ext3 is pretty fast: 
http://linuxgazette.net/122/piszcz.html
However I have no clue how ext3 behaves with >8Tb filesystems.

Anybody ?

Grtz Ramon

-- 
To be stupid and selfish and to have good health are the three requirements for happiness, though if stupidity is lacking, the others are useless.

Gustave Flaubert

  
  



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
