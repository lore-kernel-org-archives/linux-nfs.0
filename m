From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Clustered NFS?
Date: Fri, 24 May 2002 17:16:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020524171630.A3132@wumpus.internal.keyresearch.com>
References: <OF9BD0A326.21A8F516-ON88256BC3.008259B0@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nixon.xkey.com ([209.245.148.124])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BPEE-000219-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 17:16:14 -0700
Received: (from lindahl@localhost)
	by localhost.conservativecomputer.com (8.11.6/8.11.0) id g4P0GUx03147
	for nfs@lists.sourceforge.net; Fri, 24 May 2002 17:16:30 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <OF9BD0A326.21A8F516-ON88256BC3.008259B0@boulder.ibm.com>; from juang@us.ibm.com on Fri, May 24, 2002 at 04:46:22PM -0700
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

On Fri, May 24, 2002 at 04:46:22PM -0700, Juan Gomez wrote:

> Is there any software project/patch attempting to create a clustered
> version of NFS? What I mean is a version of NFS where lockd/statd state can
> be migrated from server to server? Any standard for this?

Juan,

"cluster" is a very general word. It seems that you're asking about
high availability NFS, i.e. the ability to have a failed server be
replaced by a standby server.

http://linux-ha.org/ is an overall page for high availability Linux
efforts. It looks like SGI's Failsafe project has GPLed code to both
support NFS failover using shared disks and maybe even NFS failover
using non-shared disks.

greg


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
