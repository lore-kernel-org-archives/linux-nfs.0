From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Re: lockd grace period
Date: Tue, 1 Feb 2005 07:50:30 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0502010745140.8434@harp.ngdc.noaa.gov>
References: <20050201104608.17913.qmail@web51608.mail.yahoo.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net, steved@redhat.com, chetan@hp.com
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvzMn-0004aC-9R
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 06:50:57 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvzMk-0003XF-La
	for nfs@lists.sourceforge.net; Tue, 01 Feb 2005 06:50:56 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050201104608.17913.qmail@web51608.mail.yahoo.com>
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

On Tue, 1 Feb 2005, mehta kiran wrote:

> What i think is that suse does it right by restarting nfs grace period of
> already running lockd.  This is because machine acting as nfs server can
> definitely act as nfs client of some other machine(though rare but occurs).

for us it is not rare; we do it all the time.  do i understand correctly; that
the result of NOT re-entering grace period in servant mode would be failure to
re-claim locks?

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
