From: Jason Keltz <jas@cse.yorku.ca>
Subject: Re: fsid question
Date: Tue, 27 Mar 2007 10:57:34 -0400
Message-ID: <460930DE.50507@cse.yorku.ca>
References: <46082D10.1060301@cse.yorku.ca> <46083474.8090906@redhat.com>
	<46091325.6050403@cse.yorku.ca>
	<46091498.6030706@moving-picture.com>
	<46091C41.6070908@cse.yorku.ca>
	<460929BA.9060509@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: James Pearson <james-p@moving-picture.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWD7B-00032i-Qq
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 07:57:37 -0700
Received: from bronze.cs.yorku.ca ([130.63.90.34])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWD7C-0000UF-HC
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 07:57:40 -0700
In-Reply-To: <460929BA.9060509@moving-picture.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 03/27/07 10:27, James Pearson wrote:
> Jason Keltz wrote:
> 
>> Hi James.
>>
>> Thanks for your message.
>>
>> I'm not sure that I understand this though.  If the system is 
>> generating an fsid for NFS exports in the absence of a user-specified 
>> fsid, then changing the fsid and re-exporting the filesystem *should* 
>> essentially confuse the client? How does one choose an fsid that is 
>> not already in use on the system? I imagine there must be some way to 
>> list the currently used fsids for exported filesystems.
> 
> See the thread starting at:
> 
> <http://marc.info/?l=linux-nfs&m=110295083427898&w=2>

That makes sense, but what is still not clear to me is why I can't have 
the system show me the existing fsid that it is using in the absence of 
a user-specified fsid.

Jason.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
