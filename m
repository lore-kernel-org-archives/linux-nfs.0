From: Bryan O'Sullivan <bos@serpentine.com>
Subject: Re: NFS & Clustering
Date: 04 Sep 2002 09:03:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1031155426.25370.2.camel@plokta.s8.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marco.Schwarz@Freudenberg.de
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

On Wed, 2002-09-04 at 01:35, Marco.Schwarz@Freudenberg.de wrote:

> we are looking into the possibility of building a clustered NFS-root server
> for our diskless clients. Does anybody know if this is possible with NFS and
> which cluster software is best for this task (OpenMOSIX ?).

It isn't possible without a modified mountd that replicates mount
information.  I haven't seen any free NFS servers that do this, but I
haven't looked very hard.

	<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
