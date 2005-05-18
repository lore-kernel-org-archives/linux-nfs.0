From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 15:20:22 -0400
Message-ID: <20050518192022.GF5164@fieldses.org>
References: <428B82EA.7050509@RedHat.com> <200505181912.j4IJCS8v011808@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Steve Dickson' <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYU5u-0003Mg-Ox
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:20:38 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYU5q-0007Sd-6b
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:20:38 -0700
To: Henrik Schmiediche <henrik@stat.tamu.edu>
In-Reply-To: <200505181912.j4IJCS8v011808@s7.stat.tamu.edu>
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
