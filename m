From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: RE: debugging failed lock recovery
Date: Fri, 28 Jan 2005 10:40:09 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501281038590.7869@harp.ngdc.noaa.gov>
References: <482A3FA0050D21419C269D13989C6113085396A0@lavender-fe.eng.netapp.com>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CueaZ-00011k-0X
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 14:27:39 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CueaW-0008T0-ID
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 14:27:38 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Cua6W-0008DE-Rv
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 09:40:21 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C6113085396A0@lavender-fe.eng.netapp.com>
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

On Fri, 28 Jan 2005, Lever, Charles wrote:

> hardwiring the results of gethostbyname on the client and server by
> seeding entries in /etc/hosts might be a start.

hmmm.  seems like mapping the backdoor to the frontdoor name (uname -n) would
cause other problems wouldn't it?

> i believe there is also an option on statd to always use a particular
> nodename (-n ?).

this sounds promising.  i'll look into it.

thanks for all the help!

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
