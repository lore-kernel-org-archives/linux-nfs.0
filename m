From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 14:30:38 -0500
Message-ID: <200505181931.j4IJV9Xn013359@s7.stat.tamu.edu>
References: <20050518192022.GF5164@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYUGO-0004kr-C7
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:31:28 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYUGM-0004tl-I1
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:31:28 -0700
To: "'J. Bruce Fields'" <bfields@fieldses.org>
In-Reply-To: <20050518192022.GF5164@fieldses.org>
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


Nope. Nothing there or in any any of the log files in /var/log/
 
  - Henrik


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of J. Bruce Fields
Sent: Wednesday, May 18, 2005 2:20 PM
To: Henrik Schmiediche
Cc: 'Steve Dickson'; nfs@lists.sourceforge.net
Subject: Re: [NFS] Extremely high load on NFS clients wen the NFS server is
down...

On Wed, May 18, 2005 at 02:11:58PM -0500, Henrik Schmiediche wrote:
>      Steve,
> Thanks for your response. The command 'echo t > /proc/sysrq-trigger' does
> nothing that I can tell.

Check your logs--it should have dumped a bunch of task information into
/var/log/messages.

--b.


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
