From: Frank van Maarseveen <F.vanMaarseveen@inter.NL.net>
Subject: Re: nfs permissions / access problem
Date: Tue, 13 Aug 2002 20:06:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020813200609.A5627@iapetus.localdomain>
References: <F118hBAgKR7ANimhYOj0000f31f@hotmail.com> <20020813143423.QHGF221.sccrmhc02.attbi.com@there>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from grootstal.nijmegen.internl.net ([217.149.192.7])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eg5n-0008W9-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 11:08:31 -0700
To: Neal Lippman <nl@lippman.org>
In-Reply-To: <20020813143423.QHGF221.sccrmhc02.attbi.com@there>; from nl@lippman.org on Tue, Aug 13, 2002 at 10:38:08AM -0400
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Aug 13, 2002 at 10:38:08AM -0400, Neal Lippman wrote:
> 
> Following what I would have done for a local directory, I created the 
> directory: /shared and set its ownship to root, with group=sharedgroup, and 
> then gave group permissions of rwx. I made sure each user who needs to use 
> the shared directory is in the sharedgroup on the server, and for good 
> measure also did so on each workstation (and yes, the gid's are the same on 
> each machine). Unfortunately, the directory remains inaccessible via nfs with 
> this scheme.

Just a guess:

Only the first 16 groups ids of the secondary group list are sent to the
server (RPC protocol limitation). Try the

	groups

command and when "sharedgroup" is the seventeenth or more on the
NFS client then it's the cause of the problem. In that case, see
http://web.inter.nl.net/users/fvm for a patch or re-arrange the group
memberships.

-- 
Frank


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
