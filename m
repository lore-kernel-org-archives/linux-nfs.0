From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: rpc.statd -n
Date: Wed, 2 Feb 2005 13:08:04 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502021258240.8434@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C611307CF4BCB@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwQnF-0006fX-An
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 12:08:05 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CwQnE-0007nK-UV
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 12:08:05 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4BCB@lavender-fe.eng.netapp.com>
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

On Wed, 2 Feb 2005, Lever, Charles wrote:

thanks for the info charles-

> statd is a user-level thing.

i though only lockd could be userland?

> it has nothing to do with mount or the mount options.

i realize that - i'm just suggesting that it should since nlm is all it's used
for.

> everything should work properly with multi-homed clients as long as each
> client consistently uses the same unique hostname for both lockd and
> statd requests, as far as i can tell.

how can that be?  in our situation nfs runs on the back-door so server sees
client as

   client.b.ngdc.noaa.gov

now, lockd recovery fails UNLESS '-n' argument is given to rpc.statd.
however, having given the back-door name to statd, if we were to mount a
filesystem on the frontdoor this name will then be incorrect for lock recovery
on THAT server!  it seems to me that the reason this is true is exactly the
reason our recovery was failing in the first place: the hostname used by
rpc.statd has nothing to do with which interface the nfs/lockd communication
was done using and, therefore, who the server thinks holds the lock.

i HOPE i'm mistaken but this is my current (limited) understanding of the
situation.

cheers.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
