From: James Pearson <james-p@moving-picture.com>
Subject: Re: determining if a file is nfs mounted
Date: Mon, 21 Jun 2004 22:03:20 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40D74D18.2050509@moving-picture.com>
References: <Pine.LNX.4.60.0406211242120.1344@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BcVwO-0004ch-Rc
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 14:02:56 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BcVwO-0005bG-Dv
	for nfs@lists.sourceforge.net; Mon, 21 Jun 2004 14:02:56 -0700
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0406211242120.1344@harp.ngdc.noaa.gov>
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

Doesn't statfs() do this? - from the man page:

	struct statfs {
	  long    f_type;     /* type of filesystem (see below) */
	  ...

  File system types:

	...
	linux/nfs_fs.h:
	  NFS_SUPER_MAGIC       0x6969
	...

James Pearson


Ara.T.Howard wrote:
> 
> is there a reliable method of doing this?  google and the mailing list 
> seem to
> indicate that there is not...



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
