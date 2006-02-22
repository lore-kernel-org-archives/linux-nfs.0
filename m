From: Ramon van Alteren <ramon@vanalteren.nl>
Subject: Re: Writing to an NFS share truncates files on >8Tb Raid +
 LVM2
Date: Wed, 22 Feb 2006 14:15:33 +0100
Message-ID: <43FC63F5.6090809@vanalteren.nl>
References: <43FC3ED3.2060908@vanalteren.nl> <111aefd0602220459s1786fe4ewddc5c21698002e27@mail.gmail.com> <43FC6252.2030104@vanalteren.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chris Penney <penney@msu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBtqB-0007h2-Oq
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:15:35 -0800
Received: from cust.92.104.adsl.cistron.nl ([195.64.92.104] helo=router.forgottenland.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FBtqB-0001v6-9z
	for nfs@lists.sourceforge.net; Wed, 22 Feb 2006 05:15:35 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <43FC6252.2030104@vanalteren.nl>
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

Ramon van Alteren wrote:

> Anybody any experience with ext3 on filesystems >8Tb.
> Chikama pointed me to the explanation on why this doesn't work with 
> reiserfs.
>
> But now I need to figure out which filesystem I will use.
> Testing reveals that ext3 is pretty fast: 
> http://linuxgazette.net/122/piszcz.html
> However I have no clue how ext3 behaves with >8Tb filesystems.

Nevermind....

Should learn to sit on fingers longer. From the ext3 faq:


    Q: What is the largest possible size of an ext3 filesystem and of
    files on ext3?

inspired by Andreas Dilger, suggested by Christian Kujau:

Ext3 can support files up to 1TB. With a 2.4 kernel the filesystem size 
is limited by the maximal block device size, which is 2TB. In 2.6 the 
maximum (32-bit CPU) limit is of block devices is 16TB, but ext3 
supports only up to 4TB.


Ramon

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
