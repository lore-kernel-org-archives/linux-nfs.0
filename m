From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: NFS rpc.lockd
Date: Tue, 18 May 2004 08:07:42 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405180805360.24136-100000@fattire.ngdc.noaa.gov>
References: <SEA2-F32biHKwf6Ihkg0000e266@hotmail.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQ5GD-000526-Se
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 07:08:01 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQ5GD-00049a-KS
	for nfs@lists.sourceforge.net; Tue, 18 May 2004 07:08:01 -0700
To: James Bond <jamesbond_422@hotmail.com>
In-Reply-To: <SEA2-F32biHKwf6Ihkg0000e266@hotmail.com>
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

On Tue, 18 May 2004, James Bond wrote:

> Hi,
> I am using Red Hat Enterprise Linux AS 3 kernel version:2.4.21-9.0.3.EL
> I would like to know more information about rpc.lockd daemon. Red hat 
> documenttaion says, that it is a optional process and most of the kernel now 
> days starts the rpc.lockd automatically..
> Can anyone lete me know if i need to start this services or RHEL3 kernel 
> starts this service by itself.
> 
> Thanks
> Jerry

  ~ > uname -srm
  Linux 2.4.21-15.ELsmp i686

  ~ > /sbin/chkconfig --list nfslock
  nfslock         0:off   1:off   2:off   3:on    4:on    5:on    6:off

  ~ > grep chkconfig /etc/init.d/nfslock 
  # chkconfig: 345 14 86


it's like this on all of our enterprise machines which, as far as i know, are
patched to the latest level.

cheers.

ps.  i'd kill to have your name.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| "640K ought to be enough for anybody." - Bill Gates, 1981
===============================================================================



-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
